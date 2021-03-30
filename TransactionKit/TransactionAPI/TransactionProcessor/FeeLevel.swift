//
//  FeeLevel.swift
//  PlatformKit
//
//  Created by Alex McGregor on 10/15/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public enum FeeLevel: Equatable {
    case none
    case regular
    case priority
    case custom
}

extension Collection where Element == FeeLevel {
    /// If there's more than one `FeeLevel` (excluding `.none`)
    /// than the transaction supports adjusting the `FeeLevel`
    public var networkFeeAdjustmentSupported: Bool {
        filter { $0 != .none }.count > 1
    }
}
