// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

struct AccountPickerRow: Equatable, Identifiable {

    enum Kind: Equatable {
        case button(ButtonModel)
        case linkedBankAccount(LinkedBankAccountModel)
        case accountGroup(AccountGroupModel)
        case singleAccount(SingleAccountModel)
    }

    var id = UUID()
    var kind: Kind
}

// MARK: Row Models

/// Different models for different kind of Account Picker's rows
extension AccountPickerRow {

    struct ButtonModel: Equatable {}

    struct LinkedBankAccountModel: Equatable {}

    struct AccountGroupModel: Equatable {
        typealias Dependencies = AccountPickerRowCryptoCurrencyQuote

        init(dependencies: Dependencies) {
            title = dependencies.cryptoCurrency.name
            description = dependencies.cryptoCurrency.description
            fiatBalance = dependencies.formattedQuote
            cryptoBalance = dependencies.formattedPriceChange
        }

        var title: String
        var description: String
        var fiatBalance: String
        var cryptoBalance: String
        var logo: Image?
    }

    struct SingleAccountModel: Equatable {}
}

// MARK: Account Group Dependencies and Mock

/// The goal of this is to create a "ready to use" dependency for the Account Group kind, in order to make the appropiate mapping
protocol AccountPickerRowCryptoCurrency {
    var name: String { get }
    var description: String { get }
}

protocol AccountPickerRowCryptoCurrencyQuote {
    var cryptoCurrency: AccountPickerRowCryptoCurrency { get }
    var formattedQuote: String { get }
    var formattedPriceChange: String { get }
}

extension AccountPickerRow {

    struct AccountGroupModelDependencies: AccountGroupModel.Dependencies {
        let cryptoCurrency: AccountPickerRowCryptoCurrency
        let formattedQuote: String
        let formattedPriceChange: String

        init(cryptoCurrencyQuote: AccountPickerRowCryptoCurrencyQuote
        ) {
            cryptoCurrency = cryptoCurrencyQuote.cryptoCurrency
            formattedQuote = cryptoCurrencyQuote.formattedQuote
            formattedPriceChange = cryptoCurrencyQuote.formattedPriceChange
        }
    }

    enum AccountGroupRowMockFactory {

        private struct CryptoCurrency: AccountPickerRowCryptoCurrency {
            let name: String
            let description: String
        }

        private struct CryptoCurrencyQuote: AccountPickerRowCryptoCurrencyQuote {
            var cryptoCurrency: AccountPickerRowCryptoCurrency
            let formattedQuote: String
            let formattedPriceChange: String
        }

        static func makeRow(
            name: String,
            description: String,
            formattedQuote: String,
            formattedPriceChange: String
        ) -> AccountPickerRow {
            let cryptoCurrency = CryptoCurrency(name: name, description: description)
            let cryptoCurrencyQuote = CryptoCurrencyQuote(
                cryptoCurrency: cryptoCurrency,
                formattedQuote: formattedQuote,
                formattedPriceChange: formattedPriceChange
            )
            let dependencies = AccountGroupModelDependencies(cryptoCurrencyQuote: cryptoCurrencyQuote)
            let accountGroupModel = AccountGroupModel(dependencies: dependencies)
            return AccountPickerRow(kind: .accountGroup(accountGroupModel))
        }
    }
}
