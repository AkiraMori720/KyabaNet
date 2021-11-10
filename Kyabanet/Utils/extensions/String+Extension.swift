//
//  String+Extension.swift
//  Life
//
//  Created by mac on 2021/6/18.
//  Copyright © 2021 Zed. All rights reserved.
//

import Foundation
import CryptoSwift
extension String {

    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        return data
    }
    
    func decryptedFloat() -> Float {

        let _bytes:[UInt8]? = self.hexadecimal?.bytes
        //let s = String(format: "%.2f", value)
        guard let bytes = _bytes else {
            return 0
        }
        if let aes = try? AES(key: LIFE_CRYPT.key, iv: LIFE_CRYPT.iv),
           let aesD = try? aes.decrypt(bytes) {
            
            if let balanceDecrypted = String(bytes: aesD, encoding: .utf8) {
                return (balanceDecrypted as NSString).floatValue
            }
        }
        return 0
    }
    
    func decryptedString() -> String {

        let _bytes:[UInt8]? = self.hexadecimal?.bytes
        //let s = String(format: "%.2f", value)
        guard let bytes = _bytes else {
            return ""
        }
        if let aes = try? AES(key: LIFE_CRYPT.key, iv: LIFE_CRYPT.iv),
           let aesD = try? aes.decrypt(bytes) {
            
            if let balanceDecrypted = String(bytes: aesD, encoding: .utf8) {
                return balanceDecrypted
            }
        }
        return ""
    }
    
    func encryptedString() -> String {
        let bytes:[UInt8] = Array(self.utf8)
        
        if let aes = try? AES(key: LIFE_CRYPT.key, iv: LIFE_CRYPT.iv),
           let aesE = try? aes.encrypt(bytes) {
            return Data(aesE).hexadecimal
        }
        return ""
    }

    
}
