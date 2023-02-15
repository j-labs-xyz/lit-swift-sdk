//
//  Network.swift
//  LitProtocolSwiftSDK
//
//  Created by leven on 2023/1/13.
//

import Foundation
import PromiseKit

func fetch<T: Decodable>(_ urlString: String, requestId: String, parameters: [String: Any], decodeType: T.Type) -> Promise<T> {
    return firstly {
        URLSession.shared.dataTask(.promise, with: try makeUrlRequest(urlString, parameters: parameters, headers: ["X-Request-Id": "lit_" + requestId])).validate()
    }.map {
        return try JSONDecoder().decode(decodeType.self, from: $0.data)
    }
}

func makeUrlRequest(_ urlString: String, parameters: [String: Any], headers: [String: String]) throws -> URLRequest {
    let url = try urlString.asUrl()
    var rq = URLRequest(url: url)
    rq.httpMethod = "POST"
    rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
    rq.addValue(version, forHTTPHeaderField: "X-Lit-SDK-Version")
    rq.addValue("Swift", forHTTPHeaderField: "X-Lit-SDK-Type")
    headers.keys.forEach { key in
        rq.addValue(headers[key]!, forHTTPHeaderField: key)
    }
    rq.httpBody = try JSONSerialization.data(withJSONObject: parameters)
    return rq
}
