//
//  CurrencyLabeledButtonViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformKit

/// TODO: Handle `CryptoValue` as well
public final class CurrencyLabeledButtonViewModel: NSObject, LabeledButtonViewModelAPI {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.LabeledButtonCollectionView
    public typealias Element = Decimal

    // MARK: - Exposed Properties

    /// Accepts taps
    public let tapRelay = PublishRelay<Void>()

    public var elementOnTap: Signal<Element> {
        let amount = self.amount
        return tapRelay
            .asSignal()
            .map { amount.amount }
    }

    /// Streams the content of the relay
    public var content: Driver<ButtonContent> {
        return contentRelay.asDriver()
    }

    /// Determines the background color of the view
    public let backgroundColor: Color

    // MARK: - Private Properties

    private let contentRelay = BehaviorRelay<ButtonContent>(value: .empty)
    private let amount: FiatValue

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(amount: FiatValue,
                suffix: String? = nil,
                style: LabeledButtonViewStyle = .currency,
                accessibilityId: String) {
        let amountString = amount.toDisplayString(includeSymbol: true, format: .shortened)
        let text = [amountString, suffix].compactMap { $0 }.joined(separator: " ")
        let buttonContent = ButtonContent(
            text: text,
            font: style.font,
            color: style.textColor,
            backgroundColor: style.backgroundColor,
            border: style.border,
            cornerRadius: style.cornerRadius,
            accessibility: .init(
                id: .value("\(AccessibilityId.buttonPrefix)\(accessibilityId)"),
                label: .value(amountString)
            )
        )
        self.amount = amount
        backgroundColor = style.backgroundColor
        contentRelay.accept(buttonContent)
    }
}
