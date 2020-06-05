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

        enum LineItem {
            private static let prefix = "SimpleBuy.LineItem."
            static let themeBackgroundImageView = "\(prefix)themeBackgroundImageView."
            static let bankName = "\(prefix)bankName."
            static let iban = "\(prefix)iban."
            static let bankCountry = "\(prefix)bankCountry."
            static let accountNumber = "\(prefix)accountNumber."
            static let sortCode = "\(prefix)sortCode."
            static let bankCode = "\(prefix)bankCode."
            static let recipient = "\(prefix)recipient."
            static let amountToSend = "\(prefix)amountToSend."
            static let date = "\(prefix)date."
            static let totalCost = "\(prefix)totalCost."
            static let estimatedAmount = "\(prefix)estimatedAmount."
            static let amount = "\(prefix)amount."
            static let buyingFee = "\(prefix)buyingFee."
            static let exchangeRate = "\(prefix)exchangeRate."
            static let paymentMethod = "\(prefix)paymentMethod."
            static let orderId = "\(prefix)orderId."
            static let status = "\(prefix)status."
            static let bankTransfer = "\(prefix)bankTransfer."
            static let pending = "\(prefix)pending."
            static let cryptoAmount = "\(prefix)cryptoAmount."
            static let fiatAmount = "\(prefix)fiatAmount."
        }

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
