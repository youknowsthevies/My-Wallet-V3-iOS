//
//  CheckoutScreenPresenterContentReducer.swift
//  Blockchain
//
//  Created by Paulo on 06/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxRelay
import RxSwift
import Localization
import ToolKit
import PlatformKit
import PlatformUIKit
import BuySellKit

final class CheckoutScreenContentReducer {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout
    private typealias LocalizedSummary = LocalizedString.Summary
    private typealias AccessibilityLineItem = Accessibility.Identifier.LineItem
    private typealias AccessibilitySimpleBuy = Accessibility.Identifier.SimpleBuy
    private typealias LineItem = CheckoutCellType.LineItemType

    // MARK: - Properties

    let title: String
    let cells: [DetailsScreen.CellType]

    // MARK: - View Models

    let continueButtonViewModel: ButtonViewModel
    let cancelButtonViewModel: ButtonViewModel?
    private(set) var transferDetailsButtonViewModel: ButtonViewModel?

    // MARK: - Cell Presenters

    private let orderIdLineItemCellPresenter: DefaultLineItemCellPresenter = LineItem.orderId(nil).defaultPresenter()
    private let dateLineItemCellPresenter: DefaultLineItemCellPresenter = LineItem.date(nil).defaultPresenter()
    private let totalCostLineItemCellPresenter: DefaultLineItemCellPresenter = LineItem.totalCost(nil).defaultPresenter()
    private let buyingFeeLineItemCellPresenter: DefaultLineItemCellPresenter = LineItem.buyingFee(nil).defaultPresenter()
    private let paymentMethodLineItemCellPresenter: DefaultLineItemCellPresenter = LineItem.paymentMethod(nil).defaultPresenter()
    private let exchangeRateLineItemCellPresenter: DefaultLineItemCellPresenter = LineItem.exchangeRate(nil).defaultPresenter()
    private let statusLineItemCellPresenter: DefaultLineItemCellPresenter = LineItem.status(LocalizedString.LineItem.pending).defaultPresenter()

    private let cryptoAmountLabelPresenter: DefaultLabelContentPresenter = .init(
        knownValue: " ",
        descriptors: .h1(accessibilityIdPrefix: AccessibilitySimpleBuy.LineItem.cryptoAmount)
    )
    private let fiatAmountLabelPresenter: DefaultLabelContentPresenter = .init(
        knownValue: " ",
        descriptors: .h1(accessibilityIdPrefix: AccessibilitySimpleBuy.LineItem.fiatAmount)
    )

    private let statusBadge: DefaultBadgeAssetPresenter = .init()

    private static func notice(data: SimpleBuyCheckoutData) -> LabelContent {
        LabelContent(
            text: data.detailType.paymentMethod.checkoutNotice(cryptoCurrency: data.cryptoCurrency),
            font: .main(.medium, 12),
            color: .descriptionText,
            accessibility: .id(AccessibilityLineItem.disclaimerLabel)
        )
    }

    private static func title(data: SimpleBuyCheckoutData) -> String {
        switch data.detailType.paymentMethod {
        case .card:
            if data.hasCardCheckoutMade {
                return LocalizedString.Title.orderDetails
            } else {
                return LocalizedString.Title.checkout
            }
        case .bankTransfer:
            if let order = data.detailType.order,
                order.isPendingConfirmation {
                return LocalizedString.Title.checkout
            } else {
                return LocalizedString.Title.orderDetails
            }
        }
    }

    private static func continueButton(data: SimpleBuyCheckoutData) -> ButtonViewModel {
        let title: String
        switch data.detailType.paymentMethod {
        case .card:
            if data.hasCardCheckoutMade {
                title = data.isPending3DS ? LocalizedSummary.completePaymentButton : LocalizedSummary.continueButtonPrefix
            } else {
                title = "\(LocalizedSummary.buyButtonPrefix)\(data.cryptoCurrency.displayCode)"
            }
        case .bankTransfer:
            if let order = data.detailType.order,
                order.isPendingConfirmation {
                title = "\(LocalizedSummary.buyButtonPrefix)\(data.cryptoCurrency.displayCode)"
            } else {
                title = LocalizedSummary.continueButtonPrefix
            }
        }
        return .primary(with: title)
    }

    private static func cancelButton(data: SimpleBuyCheckoutData) -> ButtonViewModel? {
        switch (data.detailType.paymentMethod, data.hasCardCheckoutMade) {
        case (.card, true):
            return nil
        case (.card, false),
             (.bankTransfer, _):
            return .cancel(with: LocalizationConstants.cancel)
        }
    }

    // MARK: - Accessors

    func setupDidSucceed(with data: CheckoutScreenInteractor.InteractionData) {
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
        if let card = data.card {
            localizedPaymentMethod = "\(card.label) \(card.displaySuffix)"
        } else {
            localizedPaymentMethod = LocalizationConstants.SimpleBuy.Checkout.LineItem.bankTransfer
        }
        paymentMethodLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: localizedPaymentMethod))
        )
    }

    init(data: SimpleBuyCheckoutData) {

        // MARK: Presenters Setup

        let totalCost = data.fiatValue.toDisplayString()
        totalCostLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: totalCost))
        )

        fiatAmountLabelPresenter.interactor.stateRelay.accept(
            .loaded(next: .init(text: "\(totalCost) \(LocalizedSummary.of) \(data.cryptoCurrency.displayCode)"))
        )

        let statusTitle = data.detailType.order?.state.localizedDescription ?? LocalizationConstants.SimpleBuy.OrderState.pending
        statusBadge.interactor.stateRelay.accept(
            .loaded(next: .init(type: .default, description: statusTitle))
        )

        // MARK: Title Setup

        title = CheckoutScreenContentReducer.title(data: data)

        // MARK: Buttons Setup

        continueButtonViewModel = CheckoutScreenContentReducer.continueButton(data: data)
        cancelButtonViewModel = CheckoutScreenContentReducer.cancelButton(data: data)

        switch (data.detailType.paymentMethod, data.hasCardCheckoutMade, data.isPendingDepositBankWire) {
        case (.card, true, _):
            // MARK: Cells Setup

            cells = [
                .label(cryptoAmountLabelPresenter),
                .badges([statusBadge]),
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
                .badges([statusBadge]),
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
                accessibilityId: AccessibilitySimpleBuy.Checkout.Button.transferDetails
            )

            cells = [
                .label(fiatAmountLabelPresenter),
                .badges([statusBadge]),
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

extension BuySellKit.SimpleBuyPaymentMethod.MethodType {
    fileprivate func checkoutNotice(cryptoCurrency: CryptoCurrency) -> String {
        typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout
        switch self {
        case .card:
            return LocalizedString.cardNotice
        case .bankTransfer:
            return "\(LocalizedString.BankNotice.prefix) \(cryptoCurrency.displayCode) \(LocalizedString.BankNotice.suffix)"
        }
    }
}
