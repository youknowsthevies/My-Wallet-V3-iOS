// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension AccountPickerRow {

    public struct AccountGroup: Equatable, Identifiable {

        // MARK: - Public Properties

        public var fiatBalance: String
        public var currencyCode: String

        public let id: AnyHashable

        // MARK: - Internal Properties

        var title: String
        var description: String

        // MARK: - Init

        public init(
            id: AnyHashable,
            title: String,
            description: String,
            fiatBalance: String,
            currencyCode: String
        ) {
            self.id = id
            self.title = title
            self.description = description
            self.fiatBalance = fiatBalance
            self.currencyCode = currencyCode
        }
    }
}
