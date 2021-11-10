//
//  Float+Extension.swift
//  Life
//
//  Created by mac on 2021/6/18.
//  Copyright © 2021 Zed. All rights reserved.
//

import Foundation
import CryptoSwift

extension Float{
    
    func encryptedString() -> String {
        
        let s = String(format: "%.2f", self)
        let bytes:[UInt8] = Array(s.utf8)
        
        if let aes = try? AES(key: LIFE_CRYPT.key, iv: LIFE_CRYPT.iv),
           let aesE = try? aes.encrypt(bytes) {
            return Data(aesE).hexadecimal
            
        }
        return ""
    }
    
    func moneyString() -> String {
        return String(format: "%.2f", self)
    }
}
