//
//  Accessibility+AccountPicker.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 10/6/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

extension Accessibility.Identifier {
    enum AccountPicker {
        private static let prefix = "AccountPickerScreen."
        enum AccountCell {
            static let prefix = "\(AccountPicker.prefix)AccountCell."
            static let cryptoAmountLabel = "\(prefix)cryptoAmountLabel"
            static let fiatAmountLabel = "\(prefix)fiatAmountLabel"
            static let badgeImageView = "\(prefix)badgeImageView"
            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let pendingLabel = "\(prefix)pendingLabel"
        }
    }
}
