//
//  ConfirmationPageContentReducer.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 29/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

protocol ConfirmationPageContentReducing {
    /// The title of the checkout screen
    var title: String { get }
    /// The `Cells` on the `ConfirmationPage`
    var cells: [DetailsScreen.CellType] { get }
    var continueButtonViewModel: ButtonViewModel { get }
    var cancelButtonViewModel: ButtonViewModel { get }
}

final class ConfirmationPageContentReducer: ConfirmationPageContentReducing {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Transaction

    // MARK: - CheckoutScreenContentReducing

    let title: String
    var cells: [DetailsScreen.CellType]
    let continueButtonViewModel: ButtonViewModel
    let cancelButtonViewModel: ButtonViewModel

    // MARK: - Private Properties

    init() {
        title = LocalizedString.Confirmation.confirm
        cancelButtonViewModel = .cancel(with: LocalizedString.Confirmation.cancel)
        continueButtonViewModel = .primary(with: "")

        cells = []
    }

    func setup(for state: TransactionState) {
        
        continueButtonViewModel.textRelay.accept(Self.confirmCtaText(state: state))
        
        guard let pendingTransaction = state.pendingTransaction else {
            cells = []
            return
        }

        let interactors = pendingTransaction.confirmations
            .compactMap(\.formatted)
            .map { data -> (title: LabelContentInteracting, subtitle: LabelContentInteracting) in
                (DefaultLabelContentInteractor(knownValue: data.0), DefaultLabelContentInteractor(knownValue: data.1))
            }
            .map { data in
                DefaultLineItemCellInteractor(title: data.title, description: data.subtitle)
            }
            .map { interactor in
                DefaultLineItemCellPresenter(interactor: interactor, accessibilityIdPrefix: "")
            }

        let confirmationLineItems = interactors
            .reduce(into: [DetailsScreen.CellType]()) { (result, lineItem) in
                result.append(.lineItem(lineItem))
                result.append(.separator)
            }

        var disclaimer: [DetailsScreen.CellType] = []
        if TransactionFlowDescriptor.confirmDisclaimerVisibility(action: state.action) {
            let content = LabelContent(
                text: TransactionFlowDescriptor.confirmDisclaimerText(action: state.action),
                font: .main(.medium, 12),
                color: .descriptionText,
                alignment: .center,
                accessibility: .id("disclaimer")
            )
            disclaimer.append(.staticLabel(content))
        }
        cells = confirmationLineItems + disclaimer
    }

    static func confirmCtaText(state: TransactionState) -> String {
        let amount = state.pendingTransaction?.amount.toDisplayString(includeSymbol: true) ?? ""
        switch state.action {
        case .swap:
            let source = state.source?.asset.displayCode ?? ""
            let destination = (state.destination as? CryptoAccount)?.asset.displayCode ?? ""
            return String(format: LocalizedString.Swap.swapAForB, source, destination)
        case .send:
            return String(format: LocalizedString.Swap.send, amount)
        case .sell:
            return String(format: LocalizedString.Swap.sell, amount)
        case .deposit:
            return String(format: LocalizedString.Swap.deposit, amount)
        default:
            fatalError("ConfirmationPageContentReducer: \(state.action) not supported.")
        }
    }
}
