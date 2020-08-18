//
//  SymbolValue.swift
//  PlatformKit
//
//  Created by Alex McGregor on 8/7/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct SymbolValue: Decodable {
    public let symbol: String
    public let value: String
}
