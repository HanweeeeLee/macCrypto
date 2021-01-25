//
//  MetaDataModel.swift
//  CryptoFile
//
//  Created by hanwe on 2021/01/25.
//

import Cocoa
import FlexibleModelProtocol

struct MetaDataModel: FlexibleModelProtocol {
    var originalFileName: String
    var fileEncDate: Date
    var modelVersion: UInt = CommonDefine.modelVersion
}
