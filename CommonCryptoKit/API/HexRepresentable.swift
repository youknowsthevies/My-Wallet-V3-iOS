//
//  HexRepresentable.swift
//  CommonCryptoKit
//
//  Created by Jack on 19/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol DataRepresentable: Hashable {
    var data: Data { get }
    
    init(data: Data) throws
}

public protocol HexRepresentable: DataRepresentable, LosslessStringConvertible, CustomDebugStringConvertible {
    var hexValue: String { get }
}

extension HexRepresentable {
    public var description: String {
        data.hexValue
    }
}

extension HexRepresentable {
    public var debugDescription: String {
        data.hexValue
    }
}

extension HexRepresentable {
    public init?(_ description: String) {
        try? self.init(data: Data(hexValue: description))
    }
}

extension HexRepresentable {
    public var hexValue: String {
        description
    }
}
