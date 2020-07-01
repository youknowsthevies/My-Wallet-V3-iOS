//
//  String+SHA256.swift
//  CommonCryptoKit
//
//  Created by Daniel Huri on 07/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import CommonCrypto
import Foundation

extension String {
    public var sha256: String {
        guard let data = data(using: .utf8) else {
            return ""
        }
        let sha256Data = digest(input: data as NSData)
        return sha256Data.hexValue
    }

    private func digest(input: NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
}
