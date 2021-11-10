//
//  Data+Extension.swift
//  Life
//
//  Created by mac on 2021/6/20.
//  Copyright © 2021 Zed. All rights reserved.
//

import Foundation

extension Data {
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
}
