//
//  LitClient-transaction.swift
//  LitProtocolSwiftSDK
//
//  Created by leven on 2023/1/27.
//

import Foundation
import PromiseKit
import web3

public extension LitClient {
    /**
     * Signs & sends the transaction using the Provider on the given chain
     */
    func sendPKPTransaction(toAddress: String,
                            fromAddress: String,
                            value: String,
                            data: String,
                            chain: Chain,
                            auth: [String: Any],
                            publicKey: String,
                            gasPrice: String? = nil,
                            gasLimit: String? = nil) -> Promise<String> {
        
        return Promise<String> { resolver in
            
            guard self.isReady else {
                resolver.reject(LitError.LitNodeClientNotReadyError)
                return
            }
            
            let _ = signPKPTransaction(toAddress: toAddress,
                                       value: value,
                                       data: data,
                                       chain: chain,
                                       publicKey: publicKey,
                                       auth: auth,
                                       gasPrice: gasPrice,
                                       gasLimit: gasLimit).done { res in
    
                var transactionModel: EthereumTransaction?
                if var transaction = res["response"] as? [String: Any] {
                    transaction["from"] = fromAddress
                    let transactionData = try? JSONSerialization.data(withJSONObject: transaction)
                    do {
                        transactionModel = try JSONDecoder().decode(EthereumTransaction.self, from: transactionData ?? Data())
                    } catch {
                        resolver.reject(error)
                    }
                }

                if var transactionModel = transactionModel,
                   let signature = res["signature"] as? [String: Any],
                    let r = (signature["r"] as? String)?.web3.hexData,
                   let s = (signature["s"] as? String)?.web3.hexData,
                    var recid = signature["recid"] as? Int {
    
                    transactionModel.data = Data()
                    transactionModel.chainId = LIT_CHAINS[chain]?.chainId as? Int
                    recid = recid == 1 ? 28 : 27
                    recid += (transactionModel.chainId ?? -1) * 2 + 8

                    let signedTransactionModel = SignedTransaction(transaction: transactionModel, v: recid, r: r, s: s)
                    if let transactionHex = signedTransactionModel.raw?.web3.hexString {
                        let web3 = EthereumHttpClient(url: URL(string: LIT_CHAINS[chain]?.rpcUrls.first ?? "")!)
                        Task {
                            do {
                                let data = try await web3.networkProvider.send(method: "eth_sendRawTransaction", params:  [transactionHex], receive: String.self)
                                if let resDataString = data as? String {
                                    resolver.fulfill(resDataString)
                                } else {
                                    resolver.reject(LitError.UnexpectedReturnValue)
                                }
                            } catch {
                                resolver.reject(error)
                            }
                        }
                    } else {
                        resolver.reject(LitError.InvalidSignedTransaction)
                    }
                } else {
                    resolver.reject(LitError.InvalidTransactionSignature)
                }
            }.catch { error in
                resolver.reject(error)
            }
        }

    }
    
    /**
     * Crafts & signs the transaction using LitActions.signEcdsa() on the given chain
     */
    func signPKPTransaction(toAddress: String,
                            value: String,
                            data: String,
                            chain:Chain,
                            publicKey: String,
                            auth: [String: Any],
                            gasPrice: String? = nil,
                            gasLimit: String? = nil) -> Promise<[String: Any]> {
        guard self.isReady else {
            return Promise(error: LitError.LitNodeClientNotReadyError)
        }
        
        guard let chainId = LIT_CHAINS[chain]?.chainId else {
            return Promise(error: LitError.UnsupportedChainException)
        }

        
        let signLitTransaction = """
        (async () => {
          const fromAddressParam = ethers.utils.computeAddress(publicKey);
          const latestNonce = await LitActions.getLatestNonce({ address: fromAddressParam, chain });
          const txParams = {
            nonce: latestNonce,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            to: toAddress,
            value: value,
            chainId: chainId,
            data: data,
          };

          LitActions.setResponse({ response: JSON.stringify(txParams) });
          
          const serializedTx = ethers.utils.serializeTransaction(txParams);
          const rlpEncodedTxn = ethers.utils.arrayify(serializedTx);
          const unsignedTxn =  ethers.utils.arrayify(ethers.utils.keccak256(rlpEncodedTxn));

          const sigShare = await LitActions.signEcdsa({ toSign: unsignedTxn, publicKey, sigName });
        })();
        """
        
        let jsParams: [String: Any] = [
            "publicKey" : publicKey,
            "chain": chain.rawValue,
            "sigName": "sessionSig",
            "chainId" :  chainId,
            "toAddress": toAddress,
            "value": value,
            "data" : data,
            "gasPrice" : gasPrice ?? "0x4A817C800",
            "gasLimit" : gasLimit ?? 5000.web3.hexString
        ]
        return self.executeJs(code: signLitTransaction, ipfsId: nil, authSig: nil, sessionSigs: auth, authMethods: nil, jsParams: jsParams)
    }
}
