//
//  Error.swift
//  LitProtocolSwiftSDK
//
//  Created by leven on 2023/1/13.
//

import Foundation
public enum LitError: Error {
    case LitNodeClientNotReadyError
    case UnsupportedChainException
    case UnknownSignatureType
    case InvalidPublicKey
    case InvalidCombinedShares
    case InvalidTransactionSignature
    case InvalidSignedTransaction
    case EmptyJSResource
    case ClientDeinit
    case UnexpectedReturnValue
    case InvalidKeyPair
    case InvalidUrl(String)
}
