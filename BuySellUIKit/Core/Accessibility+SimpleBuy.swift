//
//  Accessibility+SimpleBuy.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

extension Accessibility.Identifier {

    enum SimpleBuy {

        enum IntroScreen {
            private static let prefix = "Intro."
            static let themeBackgroundImageView = "\(prefix)themeBackgroundImageView"
        }

        enum BuyScreen {
            private static let prefix = "Buy."
            static let minimumBuy = "\(prefix)MinimumBuy"
            static let maximumBuy = "\(prefix)MaximumBuy"
            static let traillingActionButton = "\(prefix)TraillingActionButton"
        }

        enum Checkout {
            private static let prefix = "Checkout."
            static let lineItemPrefix = prefix
            static let cryptoAmountPrefix = prefix + Accessibility.Identifier.LineItem.Transactional.cryptoAmount
            static let fiatAmountPrefix = prefix + Accessibility.Identifier.LineItem.Transactional.fiatAmount
            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let disclaimerLabel = "\(prefix)disclaimerLabel"
            static let disclaimerImage = "\(prefix)disclaimerImage"

            public enum Button {
                static let transferDetails = "\(prefix)transferDetails"
            }
        }

        enum TransferDetails {
            private static let prefix = "TransferDetails."
            static let lineItemPrefix = prefix
            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let disclaimerLabel = "\(prefix)disclaimerLabel"
            static let disclaimerImage = "\(prefix)disclaimerImage"
        }

        enum Cancellation {
            private static let prefix = "Cancellation."
            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let yesButton = "\(prefix)yesButton"
            static let noButton = "\(prefix)noButton"
        }

        enum IneligibleCurrency {
            private static let prefix = "IneligibleCurrency."
            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let changeCurrency = "\(prefix)changeCurrency"
            static let viewHome = "\(prefix)viewHome"
        }
    }
}

extension Accessibility.Identifier.SimpleBuy {
    enum KYCScreen {
        static let titleLabel = "titleLabel"
        static let subtitleLabel = "subtitleLabel"
        static let goToWalletButton = "goToWalletButton"
    }
}

