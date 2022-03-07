// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    enum Coin {
        enum Label {
            enum Title {
                static let aboutCrypto = NSLocalizedString(
                    "About %@",
                    comment: "Coin View: About crypto title"
                )
            }
        }

        enum Link {
            enum Title {
                static let visitWebsite = NSLocalizedString(
                    "Visit Website ->",
                    comment: "Coin View: Visit website link title"
                )
            }
        }

        enum Button {
            enum Title {
                static let buy = NSLocalizedString(
                    "Buy",
                    comment: "Coin View: Buy CTA"
                )
                static let sell = NSLocalizedString(
                    "Sell",
                    comment: "Coin View: Sell CTA"
                )
                static let send = NSLocalizedString(
                    "Send",
                    comment: "Coin View: Send CTA"
                )
                static let receive = NSLocalizedString(
                    "Receive",
                    comment: "Coin View: Receive CTA"
                )
            }
        }
    }
}
