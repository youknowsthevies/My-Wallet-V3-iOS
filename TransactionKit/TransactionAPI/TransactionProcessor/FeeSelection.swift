//
//  FeeSelection.swift
//  TransactionKit
//
//  Created by Alex McGregor on 3/18/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct FeeSelection: Equatable {
    public var selectedLevel: FeeLevel = .none
    public var customAmount: MoneyValue?
    public var availableLevels: Set<FeeLevel> = [.none]
    public var customLevelRates: FeeLevelRates?
    public var feeState: FeeState?
    public var asset: CryptoCurrency?
    
    public init(selectedLevel: FeeLevel,
                availableLevels: Set<FeeLevel>,
                asset: CryptoCurrency) {
        self.selectedLevel = selectedLevel
        self.availableLevels = availableLevels
        self.asset = asset
    }
    
    public func update(amount: MoneyValue?, feeLevel: FeeLevel) -> FeeSelection {
        precondition(availableLevels.contains(feeLevel))
        var copy = self
        copy.customAmount = amount
        copy.selectedLevel = feeLevel
        return copy
    }
    
    public func update(selectedFeeLevel: FeeLevel) -> FeeSelection {
        precondition(availableLevels.contains(selectedFeeLevel))
        var copy = self
        copy.selectedLevel = selectedFeeLevel
        return copy
    }
    
    public static func empty(asset: CryptoCurrency) -> FeeSelection {
        .init(selectedLevel: .none, availableLevels: [.none], asset: asset)
    }
}
