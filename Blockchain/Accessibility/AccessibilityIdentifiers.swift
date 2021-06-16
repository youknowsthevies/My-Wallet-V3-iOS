// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

class AccessibilityIdentifiers: NSObject {

    struct PinScreen {
        static let prefix = "PinScreen."

        static let pinSecureViewTitle = "\(prefix)titleLabel"
        static let pinIndicatorFormat = "\(prefix)pinIndicator-"

        static let errorLabel = "\(prefix)errorLabel"
    }

    struct Address {
        static let prefix = "AddressScreen."
        static let pageControl = "\(prefix)pageControl"
    }

    enum TabViewContainerScreen {
        static let activity = "TabViewContainerScreen.activity"
        static let swap = "TabViewContainerScreen.swap"
        static let home = "TabViewContainerScreen.home"
        static let send = "TabViewContainerScreen.send"
        static let request = "TabViewContainerScreen.request"
    }

    // MARK: - Navigation

    enum Navigation {
        private static let prefix = "NavigationBar."

        enum Button {
            private static let prefix = "\(Navigation.prefix)Button."

            static let qrCode = "\(prefix)qrCode"
            static let dismiss = "\(prefix)dismiss"
            static let menu = "\(prefix)menu"
            static let help = "\(prefix)help"
            static let back = "\(prefix)back"
            static let error = "\(prefix)error"
            static let activityIndicator = "\(prefix)activityIndicator"
        }
    }

    // MARK: - Asset Selection

    struct AssetSelection {
        private static let prefix = "AssetSelection."

        static let toggleButton = "\(prefix)toggleButton"
        static let assetPrefix = "\(prefix)"
    }
}
