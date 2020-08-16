//
//  Address.swift
//  PlatformKit
//
//  Created by Paulo on 30/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol SendTarget {
    var label: String { get }
}

public protocol ReceiveAddress: SendTarget { }

enum ReceiveAddressError: Error {
    case notSupported
}

protocol CryptoAddress : ReceiveAddress {
    var asset: CryptoCurrency { get }
    var address: String { get }
}

class NullAddress: ReceiveAddress {
    let label: String = ""
}
