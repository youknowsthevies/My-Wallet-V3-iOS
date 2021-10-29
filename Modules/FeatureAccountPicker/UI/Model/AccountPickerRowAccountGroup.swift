// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableNavigation
import SwiftUI

extension AccountPickerRow {

    public struct AccountGroup: Equatable, Identifiable {

        // MARK: - Public Properties

        public let id: AnyHashable

        // MARK: - Internal Properties

        var title: String
        var description: String

        // MARK: - Init

        public init(
            id: AnyHashable,
            title: String,
            description: String
        ) {
            self.id = id
            self.title = title
            self.description = description
        }
    }
}

extension AccountPickerRow.AccountGroup {

    public struct Balances {

        // MARK: - Public Properties

        public var fiatBalance: LoadingState<String>
        public var currencyCode: LoadingState<String>

        // MARK: - Init

        public init(
            fiatBalance: LoadingState<String>,
            currencyCode: LoadingState<String>
        ) {
            self.fiatBalance = fiatBalance
            self.currencyCode = currencyCode
        }
    }
}
