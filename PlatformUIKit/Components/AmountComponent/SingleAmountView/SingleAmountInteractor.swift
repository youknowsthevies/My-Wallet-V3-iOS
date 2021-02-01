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
        case overMaxLimit(MoneyValue)
        case underMinLimit(MoneyValue)
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
    public let inputCurrency: Currency

    // MARK: - Private
    private let currencyService: CurrencyServiceAPI

    private let disposeBag = DisposeBag()

    public init(currencyService: CurrencyServiceAPI,
                inputCurrency: Currency) {
        self.currencyService = currencyService
        self.inputCurrency = inputCurrency
        self.currencyInteractor = InputAmountLabelInteractor(currency: inputCurrency)

        self.amount = currencyInteractor
            .scanner
            .input
            .compactMap { [inputCurrency] input -> MoneyValue? in
                let amount = input.isEmpty || input.isPlaceholderZero ? "0" : input.amount
                return MoneyValue.create(major: amount,
                                         currency: inputCurrency.currency)
            }
            .share(replay: 1, scope: .whileConnected)
    }

    public func connect(input: Driver<Input>) -> Driver<State> {
        // Input Actions
        input.map(\.toInputScannerAction)
            .asObservable()
            .bindAndCatch(to: currencyInteractor.scanner.actionRelay)
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

    public func set(amount: MoneyValue) {
        currencyInteractor
            .scanner
            .reset(to: amount)
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
        case .empty, .overMaxLimit, .underMinLimit:
            return .invalid
        }
    }
}
