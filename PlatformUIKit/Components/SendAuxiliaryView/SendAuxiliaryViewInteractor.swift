//
//  SendAuxiliaryViewInteractor.swift
//  PlatformUIKit
//
//  Created by Daniel on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public protocol SendAuxiliaryViewInteractorAPI: AnyObject {
    var resetToMaxAmount: Observable<Void> { get }

    var availableBalanceContentViewInteractor: ContentLabelViewInteractorAPI { get }
    
    var networkFeeContentViewInteractor: ContentLabelViewInteractorAPI { get }
    
    var networkFeeTappedRelay: PublishRelay<Void> { get }

    var availableBalanceTappedRelay: PublishRelay<Void> { get }

    var resetToMaxAmountRelay: PublishRelay<Void> { get }

    var imageRelay: PublishRelay<ImageViewContent> { get }
}

public extension SendAuxiliaryViewInteractorAPI {
    /// Streams reset to max events
    var resetToMaxAmount: Observable<Void> {
        resetToMaxAmountRelay
            .asObservable()
    }
    
    /// Streams network fee tap events
    var networkFeeTapped: Observable<Void> {
        networkFeeTappedRelay
            .asObservable()
    }

    var availableBalanceTapped: Observable<Void> {
        availableBalanceTappedRelay
            .asObservable()
    }
}

public final class SendAuxiliaryViewInteractor: SendAuxiliaryViewInteractorAPI {

    public let availableBalanceContentViewInteractor: ContentLabelViewInteractorAPI
    public let resetToMaxAmountRelay = PublishRelay<Void>()
    public let networkFeeTappedRelay = PublishRelay<Void>()
    public let availableBalanceTappedRelay = PublishRelay<Void>()
    public let networkFeeContentViewInteractor: ContentLabelViewInteractorAPI
    public let imageRelay = PublishRelay<ImageViewContent>()

    @available(*, deprecated, message: "Use `init(currencyType:coincore:)` method instead which uses the Coincore API")
    public init(balanceProvider: BalanceProviding, currencyType: CurrencyType) {
        availableBalanceContentViewInteractor = AvailableBalanceContentViewInteractor(
            balanceProvider: balanceProvider,
            currencyType: currencyType
        )
        /// NOTE: Not used in `Sell` which is the only place
        /// where this initializer is called
        networkFeeContentViewInteractor = EmptyNetworkFeeContentInteractor()
    }

    public init(currencyType: CurrencyType,
                coincore: Coincore = resolve()) {
        availableBalanceContentViewInteractor = AvailableBalanceContentInteractor(
            currencyType: currencyType,
            coincore: coincore
        )
        /// NOTE: Not used in `Withdraw` which is the only place
        /// where this initializer is called
        networkFeeContentViewInteractor = EmptyNetworkFeeContentInteractor()
    }
}
