//
//  TransactionFlowDescriptor.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 11/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import ToolKit

final class TransactionFlowDescriptor {

    private typealias LocalizedString = LocalizationConstants.Transaction

    enum EnterAmountScreen {
        private static let cryptoFormatterProvider = CryptoFormatterProvider()
        private static func formatForHeader(moneyValue: MoneyValue) -> String {
            if let cryptoValue = moneyValue.cryptoValue {
                let formatter = cryptoFormatterProvider.formatter(
                    locale: .current,
                    cryptoCurrency: cryptoValue.currencyType,
                    minFractionDigits: 2
                )
                return formatter.format(value: cryptoValue,
                                        withPrecision: .short,
                                        includeSymbol: true)
            }
            return moneyValue.displayString
        }

        static func headerTitle(state: TransactionState) -> String {
            switch state.action {
            case .swap:
                let prefix = "\(LocalizedString.Swap.swap): "
                guard let moneyValue = try? state.moneyValueFromSource().get() else {
                    return prefix
                }
                return prefix + formatForHeader(moneyValue: moneyValue)
            case .send:
                let prefix = "\(LocalizedString.Send.from): "
                guard let source = state.source else {
                    return prefix
                }
                return prefix + source.label
            case .deposit,
                 .receive,
                 .sell,
                 .viewActivity,
                 .withdraw:
                unimplemented()
            }
        }

        static func headerSubtitle(state: TransactionState) -> String {
            switch state.action {
            case .swap:
                let prefix = "\(LocalizedString.receive): "
                guard let moneyValue = try? state.moneyValueFromDestination().get() else {
                    return prefix
                }
                return prefix + formatForHeader(moneyValue: moneyValue)
            case .send:
                let prefix = "\(LocalizedString.Send.to): "
                guard let destination = state.destination else {
                    return prefix
                }
                if let address = destination as? CryptoReceiveAddress {
                    return prefix + address.address
                }
                guard let account = destination as? BlockchainAccount else {
                    return prefix
                }
                return prefix + account.label
            case .deposit,
                 .receive,
                 .sell,
                 .viewActivity,
                 .withdraw:
                unimplemented()
            }
        }
    }

    enum AccountPicker {
        static func sourceTitle(action: AssetAction) -> String {
            switch action {
            case .swap:
                return LocalizedString.Swap.swap
            case .deposit,
                 .receive,
                 .sell,
                 .send,
                 .viewActivity,
                 .withdraw:
                return ""
            }
        }

        static func sourceSubtitle(action: AssetAction) -> String {
            switch action {
            case .swap:
                return LocalizedString.Swap.sourceAccountPicketSubtitle
            case .deposit,
                 .receive,
                 .sell,
                 .send,
                 .viewActivity,
                 .withdraw:
                return ""
            }
        }

        static func destinationTitle(action: AssetAction) -> String {
            switch action {
            case .swap:
                return LocalizedString.receive
            case .deposit,
                 .receive,
                 .sell,
                 .send,
                 .viewActivity,
                 .withdraw:
                return ""
            }
        }

        static func destinationSubtitle(action: AssetAction) -> String {
            switch action {
            case .swap:
                return LocalizedString.Swap.destinationAccountPicketSubtitle
            case .deposit,
                 .receive,
                 .sell,
                 .send,
                 .viewActivity,
                 .withdraw:
                return ""
            }
        }
    }

    enum TargetSelection {
        static func navigationTitle(action: AssetAction) -> String {
            switch action {
            case .swap:
                return LocalizedString.newSwap
            case .send:
                return LocalizedString.Send.send
            case .deposit,
                 .receive,
                 .sell,
                 .viewActivity,
                 .withdraw:
                unimplemented()
            }
        }
    }

    static let networkFee = LocalizedString.networkFee
    static let availableBalanceTitle = LocalizedString.available
    static let maxButtonTitle = LocalizedString.Swap.swapMax
    
    static func maxButtonTitle(action: AssetAction) -> String {
        switch action {
        case .swap:
            return LocalizedString.Swap.swapMax
        case .send:
            return LocalizedString.Send.sendMax
        case .deposit,
             .receive,
             .sell,
             .viewActivity,
             .withdraw:
            unimplemented()
        }
    }

    static func confirmDisclaimerVisibility(action: AssetAction) -> Bool {
        switch action {
        case .swap:
            return true
        case .deposit,
             .receive,
             .sell,
             .send,
             .viewActivity,
             .withdraw:
            return false
        }
    }

    static func confirmDisclaimerText(action: AssetAction) -> String {
        switch action {
        case .swap:
            return LocalizedString.Swap.confirmationDisclaimer
        case .deposit,
             .receive,
             .sell,
             .send,
             .viewActivity,
             .withdraw:
            return ""
        }
    }
}
