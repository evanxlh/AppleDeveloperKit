//
//  AVTypes.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/17.
//

import Foundation
import CoreVideo

public extension FourCharCode {

    var fourCharCodeString: String {
        let utf16 = [
            UInt16((self >> 24) & 0xFF),
            UInt16((self >> 16) & 0xFF),
            UInt16((self >> 8) & 0xFF),
            UInt16((self & 0xFF))
        ]
        return String(utf16CodeUnits: utf16, count: 4)
    }
}

