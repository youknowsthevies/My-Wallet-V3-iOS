// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Accessibility.Identifier {

    public enum SimpleBuy {

        enum BuyScreen {
            private static let prefix = "Buy."
            static let minimumBuy = "\(prefix)MinimumBuy"
            static let maximumBuy = "\(prefix)MaximumBuy"
            static let paymentMethodTitle = "\(prefix)paymentMethodTitle"
            static let selectPaymentMethodLabel = "\(prefix)selectPaymentMethodLabel"
        }

        enum SellScreen {
            private static let prefix = "Sell."
        }

        enum PaymentMethodsScreen {
            private static let prefix = "PaymentMethods."
            static let addCard = "\(prefix)AddCard"
            static let addBank = "\(prefix)AddBank"
            static let depositCash = "\(prefix)DepositCash"
            static let linkedBank = "\(prefix)LinkedBank"
            static let useApplePay = "\(prefix)ApplePay"
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

        public enum TransferDetails {
            private static let prefix = "TransferDetails."
            public static let lineItemPrefix = prefix
            public static let titleLabel = "\(prefix)titleLabel"
            public static let descriptionLabel = "\(prefix)descriptionLabel"
            public static let disclaimerLabel = "\(prefix)disclaimerLabel"
            public static let disclaimerImage = "\(prefix)disclaimerImage"
        }
    }
}

extension Accessibility.Identifier.SimpleBuy {
    public enum KYCScreen {
        public static let titleLabel = "titleLabel"
        public static let subtitleLabel = "subtitleLabel"
        public static let goToWalletButton = "goToWalletButton"
    }
}
