//
//  CheckoutScreenPresenterContentReducer.swift
//  Blockchain
//
//  Created by Paulo on 06/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class CheckoutScreenContentReducer {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout
    private typealias LocalizedLineItem = LocalizationConstants.LineItem.Transactional
    private typealias LocalizedSummary = LocalizedString.Summary
    private typealias AccessibilityLineItem = Accessibility.Identifier.LineItem
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.Checkout
    private typealias LineItem = TransactionalLineItem

    // MARK: - Properties

    let title: String
    let cells: [DetailsScreen.CellType]

    // MARK: - View Models

    let continueButtonViewModel: ButtonViewModel
    let cancelButtonViewModel: ButtonViewModel?
    private(set) var transferDetailsButtonViewModel: ButtonViewModel?

    // MARK: - Cell Presenters

    private let orderIdLineItemCellPresenter: DefaultLineItemCellPresenter = LineItem.orderId().defaultPresenter(
        accessibilityIdPrefix: AccessibilityId.lineItemPrefix
    )
    private let dateLineItemCellPresenter: DefaultLineItemCellPresenter = LineItem.date().defaultPresenter(
        accessibilityIdPrefix: AccessibilityId.lineItemPrefix
    )
    private let totalCostLineItemCellPresenter: DefaultLineItemCellPresenter = LineItem.totalCost().defaultPresenter(
        accessibilityIdPrefix: AccessibilityId.lineItemPrefix
    )
    private let buyingFeeLineItemCellPresenter: DefaultLineItemCellPresenter = LineItem.buyingFee().defaultPresenter(
        accessibilityIdPrefix: AccessibilityId.lineItemPrefix
    )
    private let paymentMethodLineItemCellPresenter: DefaultLineItemCellPresenter = LineItem.paymentMethod().defaultPresenter(
        accessibilityIdPrefix: AccessibilityId.lineItemPrefix
    )
    private let exchangeRateLineItemCellPresenter: DefaultLineItemCellPresenter = LineItem.exchangeRate().defaultPresenter(
        accessibilityIdPrefix: AccessibilityId.lineItemPrefix
    )
    private let statusLineItemCellPresenter: DefaultLineItemCellPresenter = LineItem.status(LocalizedLineItem.pending).defaultPresenter(
        accessibilityIdPrefix: AccessibilityId.lineItemPrefix
    )

    private let cryptoAmountLabelPresenter: DefaultLabelContentPresenter = DefaultLabelContentPresenter(
        knownValue: " ",
        descriptors: .h1(accessibilityIdPrefix: AccessibilityId.cryptoAmountPrefix)
    )
    private let fiatAmountLabelPresenter: DefaultLabelContentPresenter = DefaultLabelContentPresenter(
        knownValue: " ",
        descriptors: .h1(accessibilityIdPrefix: AccessibilityId.fiatAmountPrefix)
    )

    private let statusBadge: DefaultBadgeAssetPresenter = .init()

    private static func notice(data: CheckoutData) -> LabelContent {
        LabelContent(
            text: data.order.paymentMethod.checkoutNotice(cryptoCurrency: data.cryptoCurrency),
            font: .main(.medium, 12),
            color: .descriptionText,
            accessibility: .id(AccessibilityLineItem.Base.disclaimerLabel)
        )
    }

    private static func title(data: CheckoutData) -> String {
        switch data.order.paymentMethod {
        case .card:
            if data.hasCardCheckoutMade {
                return LocalizedString.Title.orderDetails
            } else {
                return LocalizedString.Title.checkout
            }
        case .bankTransfer, .funds:
            if data.order.isPendingConfirmation {
                return LocalizedString.Title.checkout
            } else {
                return LocalizedString.Title.orderDetails
            }
        }
    }

    private static func continueButton(data: CheckoutData) -> ButtonViewModel {
        let title: String
        switch data.order.paymentMethod {
        case .card:
            if data.hasCardCheckoutMade {
                title = data.isPending3DS ? LocalizedSummary.completePaymentButton : LocalizedSummary.continueButtonPrefix
            } else {
                title = "\(LocalizedSummary.buyButtonPrefix)\(data.cryptoCurrency.displayCode)"
            }
        case .bankTransfer, .funds:
            if data.order.isPendingConfirmation {
                title = "\(LocalizedSummary.buyButtonPrefix)\(data.cryptoCurrency.displayCode)"
            } else {
                title = LocalizedSummary.continueButtonPrefix
            }
        }
        return .primary(with: title)
    }

    private static func cancelButton(data: CheckoutData) -> ButtonViewModel? {
        switch (data.order.paymentMethod, data.hasCardCheckoutMade) {
        case (.card, true):
            return nil
        case (.card, false),
             (.bankTransfer, _),
             (.funds, _):
            return .cancel(with: LocalizationConstants.cancel)
        }
    }

    // MARK: - Accessors

    func setupDidSucceed(with data: CheckoutInteractionData) {
        var formattedTime = ""
        if let time = data.time {
            formattedTime = DateFormatter.elegantDateFormatter.string(from: time)
        }
        dateLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: formattedTime))
        )
        buyingFeeLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: data.fee.toDisplayString()))
        )

        cryptoAmountLabelPresenter.interactor.stateRelay.accept(
            .loaded(next: .init(text: data.amount.toDisplayString(includeSymbol: true)))
        )

        exchangeRateLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: data.exchangeRate?.toDisplayString(includeSymbol: true) ?? ""))
        )
        orderIdLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: data.orderId))
        )

        let localizedPaymentMethod: String
        switch data.paymentMethod {
        case .funds:
            localizedPaymentMethod = "\(LocalizedLineItem.Funds.prefix) \(data.fee.currency.code) \(LocalizedLineItem.Funds.suffix)"
        case .card:
            localizedPaymentMethod = "\(data.card!.label) \(data.card!.displaySuffix)"
        case .bankTransfer:
            localizedPaymentMethod = LocalizedLineItem.bankTransfer
        }

        paymentMethodLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: localizedPaymentMethod))
        )
    }

    init(data: CheckoutData) {

        // MARK: Presenters Setup

        let totalCost = data.order.fiatValue.toDisplayString()
        totalCostLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: totalCost))
        )

        fiatAmountLabelPresenter.interactor.stateRelay.accept(
            .loaded(next: .init(text: "\(totalCost) \(LocalizedSummary.of) \(data.cryptoCurrency.displayCode)"))
        )
        
        let description = data.order.state.localizedDescription

        statusBadge.interactor.stateRelay.accept(
            .loaded(next: .init(type: .default(accessibilitySuffix: description), description: description))
        )

        // MARK: Title Setup

        title = CheckoutScreenContentReducer.title(data: data)

        // MARK: Buttons Setup

        continueButtonViewModel = CheckoutScreenContentReducer.continueButton(data: data)
        cancelButtonViewModel = CheckoutScreenContentReducer.cancelButton(data: data)
        let badgesModel = MultiBadgeCellModel()
        badgesModel.badgesRelay.accept([statusBadge])

        switch (data.order.paymentMethod, data.hasCardCheckoutMade, data.isPendingDepositBankWire) {
        case (.card, true, _):

            // MARK: Cells Setup

            cells = [
                .label(cryptoAmountLabelPresenter),
                .badges(badgesModel),
                .separator,
                .lineItem(orderIdLineItemCellPresenter),
                .separator,
                .lineItem(dateLineItemCellPresenter),
                .separator,
                .lineItem(exchangeRateLineItemCellPresenter),
                .separator,
                .lineItem(paymentMethodLineItemCellPresenter),
                .separator,
                .lineItem(buyingFeeLineItemCellPresenter),
                .separator,
                .lineItem(totalCostLineItemCellPresenter),
                .separator,
                .lineItem(statusLineItemCellPresenter),
                .staticLabel(CheckoutScreenContentReducer.notice(data: data))
            ]
        case (.card, false, _),
             (.bankTransfer, _, false):

            // MARK: Cells Setup

            cells = [
                .label(cryptoAmountLabelPresenter),
                .badges(badgesModel),
                .separator,
                .lineItem(orderIdLineItemCellPresenter),
                .separator,
                .lineItem(dateLineItemCellPresenter),
                .separator,
                .lineItem(totalCostLineItemCellPresenter),
                .separator,
                .lineItem(buyingFeeLineItemCellPresenter),
                .separator,
                .lineItem(paymentMethodLineItemCellPresenter),
                .separator,
                .staticLabel(CheckoutScreenContentReducer.notice(data: data))
            ]
        case (.funds, _, _):
            
            cells = [
                .label(cryptoAmountLabelPresenter),
                .badges(badgesModel),
                .separator,
                .lineItem(orderIdLineItemCellPresenter),
                .separator,
                .lineItem(dateLineItemCellPresenter),
                .separator,
                .lineItem(totalCostLineItemCellPresenter),
                .separator,
                .lineItem(buyingFeeLineItemCellPresenter),
                .separator,
                .lineItem(paymentMethodLineItemCellPresenter),
                .separator,
                .staticLabel(CheckoutScreenContentReducer.notice(data: data))
            ]
            
        case (.bankTransfer, _, true):

            // MARK: Cells Setup

            transferDetailsButtonViewModel = .primary(
                with: LocalizedString.Button.transferDetails,
                accessibilityId: AccessibilityId.Button.transferDetails
            )

            cells = [
                .label(fiatAmountLabelPresenter),
                .badges(badgesModel),
                .buttons([transferDetailsButtonViewModel!]),
                .separator,
                .lineItem(orderIdLineItemCellPresenter),
                .separator,
                .lineItem(dateLineItemCellPresenter),
                .separator,
                .lineItem(totalCostLineItemCellPresenter),
                .separator,
                .lineItem(buyingFeeLineItemCellPresenter),
                .separator,
                .lineItem(paymentMethodLineItemCellPresenter),
                .separator,
                .staticLabel(CheckoutScreenContentReducer.notice(data: data))
            ]
        }

    }
}

extension BuySellKit.PaymentMethod.MethodType {
    fileprivate func checkoutNotice(cryptoCurrency: CryptoCurrency) -> String {
        typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout
        switch self {
        case .card, .funds:
            return LocalizedString.finalAmountChangeNotice
        case .bankTransfer:
            return "\(LocalizedString.BankNotice.prefix) \(cryptoCurrency.displayCode) \(LocalizedString.BankNotice.suffix)"
        }
    }
}
