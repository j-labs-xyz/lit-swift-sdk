//
//  Error.swift
//  LitProtocolSwiftSDK
//
//  Created by leven on 2023/1/13.
//

import Foundation
public enum LitError: Error {
    case litNodeClientNotReady
    case invalidPublicKey
    case unknownSignatureType
    case invalidCombinedShares
    case invalidTransactionSignature
    case invalidSignedTransaction
    case unsupportedChain
    case emptyJSResource
    case clientDeinit
    case unexpectedReturnValue
    case invalidKeyPair
    case invalidUrl(String)
}
