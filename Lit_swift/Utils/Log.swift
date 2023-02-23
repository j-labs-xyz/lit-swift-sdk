//
//  Log.swift
//  Lit_swift
//
//  Created by leven on 2023/2/23.
//

import Foundation

func log(_ items: Any...) {
    guard LitSwift.enableLog else {
        return
    }
    print(items.reduce("[Lit-Swift-SDK]：", { $0 + "\($1)"}))
}
