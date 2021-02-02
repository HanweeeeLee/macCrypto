//
//  HWAESCryption.swift
//  AESTest
//
//  Created by hanwe on 2020/07/11.
//  Copyright © 2020 hanwe. All rights reserved.
//

import Foundation

extension HWAESCryption {
    
    static func aesShortEncrypt(data: Data, key: Data, aesType: HW_AES_Type) -> Data? {
        let sha = CryptoUtil().sha256(data: key)
        
        let startIndex = sha.startIndex

        let ivStartIndex = sha.startIndex
        let ivEndIndex = sha.index(startIndex, offsetBy: 16)
        let ivRange:ClosedRange = ivStartIndex...ivEndIndex
        let iv = sha.subdata(in: ivRange.lowerBound ..< ivRange.upperBound + 1)

        return HWAESCryption.aesEncrypt(originalData: data, iv: iv, key: sha, aesType: aesType)
    }
    
    static func aesShortDecrypt(encData: Data, key: Data, aesType: HW_AES_Type) -> Data? {
        let sha = CryptoUtil().sha256(data: key)
        let startIndex = sha.startIndex

        let ivStartIndex = sha.startIndex
        let ivEndIndex = sha.index(startIndex, offsetBy: 16)
        let ivRange:ClosedRange = ivStartIndex...ivEndIndex
        let iv = sha.subdata(in: ivRange.lowerBound ..< ivRange.upperBound + 1)

        return HWAESCryption.aesDecrypt(encData: encData, iv: iv, key: sha, aesType: aesType)
    }
}

