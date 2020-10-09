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

public protocol CryptoReceiveAddress: ReceiveAddress {
    var label: String { get }
    var asset: CryptoCurrency { get }
    var address: String { get }
    var metadata: CryptoAssetQRMetadata { get }
}

public enum ReceiveAddressError: Error {
    case notSupported
}
