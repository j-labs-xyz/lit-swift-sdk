//
//  LitClient-executeJs.swift
//  LitProtocolSwiftSDK
//
//  Created by leven on 2023/1/27.
//

import Foundation
import PromiseKit
extension LitClient {
    
    /**
     * Execute JS on the nodes and combine and return any resulting signatures
     */
    func executeJs(code: String?, ipfsId: String?, authSig: [String: Any]?,  sessionSigs: [String: Any]?, authMethods: [AuthMethod]?, jsParams: [String: Any], debug: Bool = true) -> Promise<Any> {
        guard self.isReady else {
            return Promise(error: LitError.litNotReady)
        }
                
        var reqBody:[String: Any] = [:]
        reqBody["authSig"] = authSig
        reqBody["jsParams"] = jsParams
        if let authMethods = authMethods {
            reqBody["authMethods"] = authMethods.map { $0.toBody() }
        }
        if let code = code {
            let encodedJs = code.data(using: .utf8)?.base64EncodedString() ?? ""
            reqBody["code"] = encodedJs
        } else if let ipfsId = ipfsId {
            reqBody["ipfsId"] = ipfsId
        } else {
            return Promise(error: LitError.emptyJSResource)
        }

        
        var urlGenerator = self.connectedNodes.makeIterator()
        let allPromises = AnyIterator<Promise<NodeShareResponse>> {
            guard let url = urlGenerator.next() else {
                return nil
            }
            if let sig = sessionSigs?[url] as? [String: Any] {
                reqBody["authSig"] = sig
            }
            return self.getJsExecutionShares(url, params: reqBody)
        }
        
        
        return Promise<Any> { resolver in
            let _ = when(fulfilled: allPromises, concurrently: 4).done { [weak self] nodeResponses in
                guard let `self` = self else {
                    return resolver.reject(LitError.clientDeinit)
                }
                let signedDataList = nodeResponses.compactMap( { $0.signedData?.sessionSig })
                let sigType =  signedDataList.map { $0.sigType }.mostCommonString
                
                var signature: [String: Any] = [:]
                if sigType == SigType.ECDSA.rawValue {
                    signature = self.combineEcdsaShares(shares: signedDataList)
                } else {
                    return resolver.reject(LitError.unsupportSigType)
                }
                
                var signatureResult: [String: Any] = signature
                signatureResult["publicKey"] = (signedDataList.compactMap { $0.publicKey }.mostCommonString ?? "").web3.withHexPrefix
                signatureResult["dataSigned"] = "0x" + (signedDataList.compactMap { $0.dataSigned }.mostCommonString ?? "").web3.withHexPrefix

                if let r = signature["r"] as? String,
                   let s = signature["s"] as? String,
                   let recid = signature["recid"] as? UInt8,
                    let joinedSignature = self.joinSignature(r: r, v: recid, s: s) {
                    signatureResult["signature"] = joinedSignature
                }
                
                let decryptedDatas = nodeResponses.compactMap( { $0.decryptedData })

                let response: String = nodeResponses.compactMap( { $0.response }).mostCommonString ?? ""
                
                let responseDict = try? JSONSerialization.jsonObject(with: response.data(using: .utf8) ?? Data()) as? [String: Any] ?? [:]
                
                let logs: String = nodeResponses.compactMap( { $0.logs }).mostCommonString ?? ""

                let result: [String: Any] = [
                    "signature" : signatureResult,
                    "response" : responseDict ?? [:],
                    "logs" : logs
                ]
                resolver.fulfill(result)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    func getJsExecutionShares(_ url: String, params: [String: Any]) -> Promise<NodeShareResponse>  {
        let urlWithPath = "\(url)/web/execute"
        return fetch(urlWithPath, parameters: params, decodeType: NodeShareResponse.self)
    }
}
