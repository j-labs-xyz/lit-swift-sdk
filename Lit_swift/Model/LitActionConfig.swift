//
//  LitActionConfig.swift
//  Lit_swift
//
//  Created by leven on 2023/3/5.
//

import Foundation
public struct LitActionConfig {
    public var maxEthValue: Double? = nil
    public init(maxEthValue: Double? = nil) {
        self.maxEthValue = maxEthValue
    }
    public static var `default` = LitActionConfig(maxEthValue: 0.22)
    
    var configParams: [String: Any] {
        var params: [String: Any] = [:]
        if let maxEthValue = maxEthValue {
            params["maxValueEth"] = maxEthValue
        }
        return params
    }
}
