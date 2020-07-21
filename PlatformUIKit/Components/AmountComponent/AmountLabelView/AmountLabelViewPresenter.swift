//
//  AmountLabelViewPresenter.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 24/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import ToolKit
import PlatformKit

/// A view model for `AmountLabelView` which is able to display a money amount with
/// an `valid` / `invalid` indication.
public final class AmountLabelViewPresenter {

    // MARK: - Types
    
    public enum CurrencyCodeSide {
        case leading
        case trailing
    }
    
    public struct Output {
        
        fileprivate static var empty: Output {
            Output(
                amountLabelContent: .empty,
                currencyCodeLabelContent: .empty,
                currencyCodeSide: .leading
            )
        }
        
        public var string: NSAttributedString {
            let string = NSMutableAttributedString()
            switch currencyCodeSide {
            case .leading:
                string.append(NSAttributedString(currencyCodeLabelContent))
                string.append(.init(string: "  "))
                string.append(amountLabelContent.string)
                return string
            case .trailing:
                string.append(amountLabelContent.string)
                string.append(.init(string: "  "))
                string.append(NSAttributedString(currencyCodeLabelContent))
                return string
            }
            
        }
        
        public var accessibility: Accessibility {
            amountLabelContent.accessibility
        }
        
        let amountLabelContent: AmountLabelContent
        let currencyCodeLabelContent: LabelContent
        let currencyCodeSide: CurrencyCodeSide
    }
    
    // MARK: - Properties
    
    /// Streams the amount label content
    var output: Driver<Output> {
        outputRelay.asDriver()
    }
    
    public let outputRelay = BehaviorRelay<Output>(value: .empty)
        
    /// The state of the component
    public let inputRelay = BehaviorRelay<MoneyValueInputScanner.Input>(value: .empty)
    
    private let currencyCodeContentRelay = BehaviorRelay<LabelContent>(value: .empty)
    private let amountRelay = BehaviorRelay<AmountLabelContent>(value: .empty)

    // MARK: - Injected

    private let currencyCodeSide: CurrencyCodeSide
    private let interactor: AmountLabelViewInteractor
    
    private let disposeBag = DisposeBag()
    
    public init(interactor: AmountLabelViewInteractor, currencyCodeSide: CurrencyCodeSide) {
        self.interactor = interactor
        self.currencyCodeSide = currencyCodeSide
        
        Observable
            .combineLatest(
                interactor.currency,
                interactor.state
            )
            .map { (currency, state) -> LabelContent in
                let color: Color
                switch state {
                case .invalid:
                    color = .mutedText
                case .valid:
                    color = .titleText
                }
                return LabelContent(
                    text: currency.symbol,
                    font: .main(.medium, 48),
                    color: color,
                    accessibility: .id(currency.isCryptoCurrency ? AccessibilityId.cryptoCurrencyCodeLabel : AccessibilityId.fiatCurrencyCodeLabel)
                )
            }
            .catchErrorJustReturn(.empty)
            .bindAndCatch(to: currencyCodeContentRelay)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(
                interactor.currency,
                inputRelay
            )
            .map { AmountLabelContent(input: $0.1, currencyCode: $0.0.code) }
            .bindAndCatch(to: amountRelay)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(
                amountRelay,
                currencyCodeContentRelay
            )
            .map {
                Output(
                    amountLabelContent: $0.0,
                    currencyCodeLabelContent: $0.1,
                    currencyCodeSide: currencyCodeSide
                )
            }
            .bindAndCatch(to: outputRelay)
            .disposed(by: disposeBag)
        
    }
}

// MARK: - AmountLabelContent

extension AmountLabelViewPresenter {

    // MARK: - Types
        
    private typealias AccessibilityId = Accessibility.Identifier.AmountLabelView
    
    struct AmountLabelContent {
        
        // MARK: - Properties
        
        fileprivate static var empty: AmountLabelContent {
            .init(input: .empty, currencyCode: "")
        }
        
        /// Returns the attributed string
        var string: NSAttributedString {
            let string = NSMutableAttributedString()
            string.append(.init(amount))
            
            if let placeholder = placeholder {
                string.append(.init(placeholder))
            }
            
            return string
        }
        
        let accessibility: Accessibility
        let amount: LabelContent
        let currencyCode: LabelContent
        let placeholder: LabelContent?
                
        // MARK: - Setup
        
        init(input: MoneyValueInputScanner.Input,
             currencyCode: String) {
            var amount = ""
            let formatter = NumberFormatter(
                locale: Locale.current,
                currencyCode: currencyCode,
                maxFractionDigits: 0
            )
            
            let decimalSeparator = MoneyValueInputScanner.Constant.decimalSeparator
            let amountComponents = input.amount.components(separatedBy: decimalSeparator)
            
            if let firstComponent = amountComponents.first, let decimal = Decimal(string: firstComponent) {
                amount += formatter.format(amount: decimal, includeSymbol: false)
            }
            
            if amountComponents.count == 2 {
                amount += "\(decimalSeparator)\(amountComponents[1])"
            }
            
            let font = UIFont.main(.medium, 48)

            self.currencyCode = LabelContent(
                text: currencyCode,
                font: font,
                color: .titleText)
        
            self.amount = LabelContent(
                text: amount,
                font: font,
                color: .titleText
            )
            
            accessibility = .init(
                id: .value(AccessibilityId.amountLabel),
                label: .value(amount)
            )
            
            guard let padding = input.padding else {
                placeholder = nil
                return
            }
            
            placeholder = LabelContent(
                text: padding,
                font: font,
                color: .mutedText
            )
        }
    }
}
