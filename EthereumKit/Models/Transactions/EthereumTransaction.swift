//
//  EthereumTransaction.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol EthereumTransaction {
    var isConfirmed: Bool { get }
    var confirmations: UInt { get }
}
