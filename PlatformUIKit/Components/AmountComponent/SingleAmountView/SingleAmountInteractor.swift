//
//  SingleAmountInteractor.swift
//  PlatformUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 12/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public final class SingleAmountInteractor {

    public enum Input {
        case insert(String)
        case remove
    }

    public enum State {
        case empty
        case inBounds
        case maxLimitExceeded(MoneyValue)
    }

    // MARK: - Properties

    /// The state of the component
    public let stateRelay = BehaviorRelay<State>(value: .empty)
    public var state: Observable<State> {
        stateRelay.asObservable()
            .share(replay: 1, scope: .whileConnected)
    }

    /// Streams the amount of `MoneyValue`
    public let amount: Observable<MoneyValue>

    public let currencyInteractor: InputAmountLabelInteractor
    public let currency: Currency

    // MARK: - Private
    private let currencyService: CurrencyServiceAPI

    private let disposeBag = DisposeBag()

    public init(currencyService: CurrencyServiceAPI,
                currency: Currency) {
        self.currencyService = currencyService
        self.currency = currency
        self.currencyInteractor = InputAmountLabelInteractor(currency: currency)

        self.amount = currencyInteractor
            .scanner
            .input
            .compactMap { [currency] input -> MoneyValue? in
                let amount = input.isEmpty || input.isPlaceholderZero ? "0" : input.amount
                return MoneyValue.create(major: amount,
                                         currency: currency.currency)
            }
            .share(replay: 1, scope: .whileConnected)
    }

    public func connect(input: Driver<Input>) -> Driver<State> {
        // Input Actions
        input.map(\.toInputScannerAction)
            .asObservable()
            .bind(to: currencyInteractor.scanner.actionRelay)
            .disposed(by: disposeBag)

        state
            .map(\.toValidationState)
            .bindAndCatch(to: currencyInteractor.interactor.stateRelay)
            .disposed(by: disposeBag)

        return state
            .asDriver(onErrorJustReturn: .empty)
    }

    public func set(amount: String) {
        currencyInteractor.scanner
            .rawInputRelay
            .accept(amount)
    }
}

extension SingleAmountInteractor.Input {
    internal var toInputScannerAction: MoneyValueInputScanner.Action {
        switch self {
        case .insert(let value):
            return .insert(Character(value))
        case .remove:
            return .remove
        }
    }
}

extension SingleAmountInteractor.State {
    internal var toValidationState: ValidationState {
        switch self {
        case .inBounds:
            return .valid
        case .empty, .maxLimitExceeded:
            return .invalid
        }
    }
}
