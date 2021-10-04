// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension AccountPickerRow {

    public struct Button: Equatable {

        // MARK: - Internal properties

        var text: String

        let id: AnyHashable

        // MARK: - Init

        public init(id: AnyHashable, text: String) {
            self.id = id
            self.text = text
        }
    }
}
