//
//  AmountLabelViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 24/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

/// TODO: `AmountLabelViewModel` currency supports fiat values but should be able to
/// support crypto values as well.
///
/// A view model for `AmountLabelView` which is able to display a money amount with
/// an `valid` / `invalid` indication.
public final class AmountLabelViewModel {

    // MARK: - Properties
    
    /// Streams the state of the view model
    public var state: Observable<State> {
        stateRelay.asObservable()
    }

    // Streams the image as per state
    var stateImageContent: Observable<ImageViewContent> {
        let shouldDisplayStateImage = self.shouldDisplayStateImage
        return state
            .map { state in
                switch (shouldDisplayStateImage, state) {
                case (true, .invalid) :
                    return ImageViewContent(
                        imageName: "red-error-triangle-icon",
                        accessibility: .id(AccessibilityId.errorImageView)
                    )
                default:
                    return .empty
                }
            }
    }
    
    /// Streams the content of the currency code label
    var currencyCodeLabelContent: Observable<LabelContent> {
        Observable
            .combineLatest(
                fiatCurrencyService.fiatCurrencyObservable,
                state
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
                    accessibility: .id(AccessibilityId.fiatCurrencyCodeLabel)
                )
            }
            .catchErrorJustReturn(.empty)
    }
    
    /// Streams the amount label content
    var amount: Observable<(amount: NSAttributedString, accessibility: Accessibility)> {
        Observable
            .combineLatest(
                fiatCurrencyService.fiatCurrencyObservable,
                inputRelay
            )
            .map { AmountLabelContent(input: $0.1, currencyCode: $0.0.rawValue) }
            .map { (amount: $0.string, accessibility: $0.accessibility) }
            .share(replay: 1)
    }
        
    /// The state of the component
    public let stateRelay = BehaviorRelay<State>(value: .valid)
    public let inputRelay = BehaviorRelay<MoneyValueInputScanner.Input>(value: .empty)
    
    // MARK: - Injected

    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let shouldDisplayStateImage: Bool
        
    public init(fiatCurrencyService: FiatCurrencySettingsServiceAPI, shouldDisplayStateImage: Bool = true) {
        self.fiatCurrencyService = fiatCurrencyService
        self.shouldDisplayStateImage = shouldDisplayStateImage
    }
}

// MARK: - AmountLabelContent

extension AmountLabelViewModel {

    // MARK: - Types
    
    /// The state of the view model
    public enum State {
        
        /// A valid state
        case valid
        
        /// An invalid state
        case invalid
    }
    
    private typealias AccessibilityId = Accessibility.Identifier.AmountLabelView
    
    private struct AmountLabelContent {
        
        // MARK: - Properties
        
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
        let placeholder: LabelContent?
        
        // MARK: - Setup
        
        init(input: MoneyValueInputScanner.Input, currencyCode: String) {
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
