//
//  CryptoUtil.swift
//  CryptoFile
//
//  Created by hanwe on 2021/01/25.
//

import Cocoa
import CommonCrypto

class CryptoUtil: NSObject {
    func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
}
