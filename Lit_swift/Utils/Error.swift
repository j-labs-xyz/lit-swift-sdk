//
//  Error.swift
//  LitProtocolSwiftSDK
//
//  Created by leven on 2023/1/13.
//

import Foundation
public enum LitError: Error {
    case invalidSignedTransaction
    case invalidTransaction
    case invalidChain
    case emptyJSResource
    case unsupportSigType
    case invalidPublicKey
    case litNotReady
    case emptyCapabilities
    case clientDeinit
    case unexpectedReturnValue
    case invalidNodeShares
    case invalidKeyPair
    case invalidUrl(String)
}
