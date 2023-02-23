//
//  LitSwiftSDK.swift
//  LitProtocolSwiftSDK
//
//  Created by leven on 2023/1/4.
//

import Foundation
import PromiseKit
import TweetNacl
import web3
import Libecdsa_swift
import secp256k1
public class LitClient {
    
    let config: LitNodeClientConfig
    
    var connectedNodes: Set<String> = Set<String>()
    
    let serverKeys: [String: NodeCommandServerKeysResponse] = [:]
    
    private(set) var ready: Bool = false
    
    public var isReady: Bool {
        return ready
    }
    
    var subnetPubKey: String?
    
    var networkPubKey: String?
    
    var networkPubKeySet: String?
    
    public init(config: LitNodeClientConfig? = nil) {
        self.config = config ?? LitNodeClientConfig.default()
    }

    public func connect() -> Promise<Void>  {
        // handshake with each node
        var urlGenerator = self.config.litNetwork.networks.makeIterator()
        let requestId = getRandomRequestId()
        let allPromises = AnyIterator<Promise<NodeCommandServerKeysResponse>> {
            guard let url = urlGenerator.next() else {
                return nil
            }
            return self.handshakeWithNode(url, requestId: requestId).then { response in
                
                // append the connected node url
                self.connectedNodes.insert(url)
                return Promise<NodeCommandServerKeysResponse>.value(response)
            }
        }
        
        return when(fulfilled: allPromises, concurrently: 4).done { [weak self] nodeResponses in
            guard let `self` = self else { return }
            
            // pick the most common public keys for the subnet and network from the bunch, in case some evil node returned a bad key
            self.subnetPubKey = nodeResponses.map { $0.subnetPublicKey }.mostCommonString
            self.networkPubKey = nodeResponses.map { $0.networkPublicKey }.mostCommonString
            self.networkPubKeySet = nodeResponses.map { $0.networkPublicKeySet }.mostCommonString
            self.ready = true
        }
    }
    
    /**
     * Get session signatures for a set of resources
     *
     * How this works:
     * 1. Generate session key
     * 2. Generate  the wallet signature of the session key
     * 3. Sign the specific resources with the session key
     *
     */
    public func getSessionSigs(_ params: GetSessionSigsProps) -> Promise<[String: Any]> {
        var sessionKey: SessionKeyPair
        do {
            sessionKey = try getSessionKey()
        } catch {
            return Promise(error: error)
        }
    
        let sessionKeyUrl = getSessionKeyUri(sessionKey.publicKey)
        
        guard let capabilities = getSessionCapabilities(params.sessionCapabilities, resources: params.resource) else {
            return Promise(error: LitError.emptyCapabilities)
        }
        
        let expiration = params.expiration ?? Date(timeIntervalSinceNow: 7 * 60 * 60 * 24)
        
        return getWalletSig(chain: params.chain,
                            capabilities: capabilities,
                            switchChain: params.switchChain,
                            expiration: expiration,
                            sessionKeyUri: sessionKeyUrl,
                            authNeededCallback: params.authNeededCallback).then { [weak self] authSig in
            guard let `self` = self else {
                return Promise<[String: Any]>.init(error: LitError.clientDeinit)
            }
            
            let signingTemplate: [String: Any] = [
                "sessionKey": sessionKey.publicKey,
                "resources": params.resource,
                "capabilities" : [authSig.toBody()],
                "issuedAt": Date(timeIntervalSince1970: 0).ISOString,
                "expiration": expiration.ISOString
            ]
            
            var signatures: [String: Any] = [:]
            
            do {
                try self.connectedNodes.forEach { node in
                    var toSign = signingTemplate
                    
                    toSign["nodeAddress"] = node
                    
                    let keyData = sessionKey.secretKey
                    
                    let messageData = (try? JSONSerialization.data(withJSONObject: toSign)) ?? Data()
                    
                    let signature = try NaclSign.signDetached(message: messageData, secretKey: keyData.web3.hexData ?? Data()).web3.hexString.web3.noHexPrefix
                    
                    signatures[node] = [
                        "sig": signature,
                        "derivedVia" : "litSessionSignViaNacl",
                        "signedMessage" : String(data: messageData, encoding: .utf8),
                        "address" : sessionKey.publicKey,
                        "algo": "ed25519"
                    ]
                }
            } catch {
                return Promise<[String: Any]>.init(error: error)
            }
            
            return Promise<[String: Any]>.value(signatures)
        }
    }
    
    func getSessionKey() throws -> SessionKeyPair {
        let keyPair = try NaclSign.KeyPair.keyPair()
        if let publicKey = keyPair.publicKey.toBase16String(), let secretKey = keyPair.secretKey.toBase16String() {
            return SessionKeyPair(publicKey: publicKey, secretKey: secretKey)
        }
        throw LitError.invalidKeyPair
    }
    
    /**
     * Sign a session key using a PKP
     */
    public func signSessionKey(_ params: SignSessionKeyProp) -> Promise<JsonAuthSig> {
        guard self.ready else {
            return Promise(error: LitError.litNotReady)
        }
        
        guard let addressValue = self.computeAddress(publicKey: params.pkpPublicKey) else {
            return Promise(error: LitError.invalidPublicKey)
        }
        
        let ethereumAddress = EthereumAddress(addressValue)
        let nonce = String.random(minimumLength: 96, maximumLength: 128)
        var siweMessage: SiweMessage!
        do {
            siweMessage = try SiweMessage(domain: "localhost",
                                          address: ethereumAddress.toChecksumAddress(),
                                          statement: "Lit Protocol PKP session signature",
                                          uri: URL(string: params.sessionKey)!,
                                          version: "1",
                                          chainId: 1,
                                          nonce: nonce,
                                          issuedAt: Date(),
                                          expirationTime: params.expiration,
                                          notBefore: nil,
                                          requestId: nil,
                                          resources: params.resouces.compactMap({ URL(string: $0) }))
            
        } catch {
            return Promise(error: error)
        }
        let siweMessageString = siweMessage.description
        
        let reqBody = SessionRequestBody(sessionKey: params.sessionKey,
                                         authMethods: params.authMethods,
                                         pkpPublicKey: params.pkpPublicKey,
                                         authSig: nil,
                                         siweMessage: siweMessageString)
        
        
        var urlGenerator = self.connectedNodes.makeIterator()
        let requestId = getRandomRequestId()
        let allPromises = AnyIterator<Promise<NodeShareResponse>> {
            guard let url = urlGenerator.next() else {
                return nil
            }
            // get signature shares
            return self.getSignSessionKeyShares(url, requestId: requestId, params: reqBody)
        }
        return Promise<JsonAuthSig> { resolver in
            when(fulfilled: allPromises, concurrently: 4).done ({ [weak self] nodeResponses in
                guard let `self` = self else {
                    return resolver.reject(LitError.clientDeinit)
                }
    
                let signedDataList = nodeResponses.compactMap( { $0.signedData?.sessionSig })
                
                let sigType =  signedDataList.map { $0.sigType }.mostCommonString
               
                let siweMessage = signedDataList.compactMap { $0.siweMessage }.mostCommonString ?? ""

                if sigType == SigType.ECDSA.rawValue {
                    let res = self.combineEcdsaShares(shares: signedDataList)
                    if let r = res["r"] as? String,
                       let s = res["s"] as? String,
                       let recid = res["recid"] as? UInt8,
                       let signature = self.joinSignature(r: r, v: recid, s: s) {
                        let jsonAuthSig = JsonAuthSig(sig: signature,
                                                      derivedVia: "web3.eth.personal.sign via Lit PKP",
                                                      signedMessage: siweMessage,
                                                      address: ethereumAddress.value)
                        return resolver.fulfill(jsonAuthSig)
                    } else {
                        return resolver.reject(LitError.invalidNodeShares)
                    }
                } else {
                    return resolver.reject(LitError.unsupportSigType)
                }
                
           }).catch { error in
               return resolver.reject(error)
           }
        }
     }

    /**
     * Get the signature from lit nodes
     *
     */
    func getWalletSig(chain: Chain,
                      capabilities:
    [String] = [], switchChain: Bool,
                      expiration: Date,
                      sessionKeyUri: String,
                      authNeededCallback: AuthNeededCallback) -> Promise<JsonAuthSig> {
        var capabilitiesJsonString: String
        do {
            capabilitiesJsonString = try capabilities.toBase64String()
        } catch {
            return Promise(error: error)
        }
        // convert into SIWE ReCap compliant session capability.
        let sessionCapabilities = ["urn:recap:lit:session:" + capabilitiesJsonString]
        return authNeededCallback(chain, sessionCapabilities, switchChain, expiration, sessionKeyUri)
    }
}

extension LitClient {
    func handshakeWithNode(_ url: String, requestId: String) -> Promise<NodeCommandServerKeysResponse> {
        let urlWithPath = "\(url)/web/handshake"
        let parameters = ["clientPublicKey" : "test"]
        return fetch(urlWithPath,
                     requestId: requestId,
                     parameters: parameters,
                     decodeType: NodeCommandServerKeysResponse.self)
    }
    

    func getSignSessionKeyShares(_ url: String,
                                 requestId: String,
                                 params: SessionRequestBody) -> Promise<NodeShareResponse> {
        let urlWithPath = url + "/web/sign_session_key"
        let parameters = params.toBody()
        return fetch(urlWithPath,
                     requestId: requestId,
                     parameters: parameters,
                     decodeType: NodeShareResponse.self)
    }
}


extension LitClient {
    
    func getRandomRequestId() -> String {
        return String.random(minimumLength: 8, maximumLength: 20)
    }
    
    func combineEcdsaShares(shares: [NodeShare]) -> [String: Any] {
        let r_x = shares[0].localX
        let r_y = shares[0].localY
        let validShares = shares.map { $0.signatureShare }
        let validSharesJson = try? validShares.toJsonString()
        if let res = combine_signature(r_x, ry: r_y, shares: validSharesJson ?? "") {
            return res
        }
        return [:]
    }
    
   
    func getSessionKeyUri(_ publicKey: String) -> String {
        return LIT_SESSION_KEY_URI + publicKey
    }
    
    func getSessionCapabilities(_ capabilities: [String]?, resources: [String]) -> [String]? {
        var capabilities = capabilities ?? []
        if capabilities.count == 0 {
            capabilities = resources.map({
                let (protocolType, _) = parseResource($0)
                return "\(protocolType)Capability://*"
            })
        }
        return capabilities

    }
    
    func parseResource(_ resource: String) -> (protocolType: String, resourceId: String) {
        return (resource.components(separatedBy: "://").first ?? "", resource.components(separatedBy: "://").last ?? "")
    }
   

    func computeAddress(publicKey: String) -> String? {
        var pkpPublicKeyData = publicKey.web3.hexData
        pkpPublicKeyData = pkpPublicKeyData?.dropFirst()
        if let pkpPublicKeyHash = pkpPublicKeyData?.web3.keccak256 {
            let address = pkpPublicKeyHash.subdata(in: 12..<pkpPublicKeyHash.count)
            return address.web3.hexString
        }
        return nil
    }
    
    func joinSignature(r: String, v: UInt8, s: String) -> String? {
        guard let rData = r.zeroPad(lenght: 64).web3.hexData,  let sData = s.zeroPad(lenght: 64).web3.hexData else {
            return nil
        }
        var signature = rData
        signature.append(sData)
        if v == 1 {
            signature.append(contentsOf: [0x1c])
        } else {
            signature.append(contentsOf: [0x1b])
        }
        return signature.web3.hexString
    }
}
