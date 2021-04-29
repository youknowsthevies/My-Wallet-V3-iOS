// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

extension Accessibility.Identifier {
    struct WelcomeScreen {
        static let prefix = "WelcomeScreen."
        struct Button {
            static let prefix = "\(WelcomeScreen.prefix)Button."
            static let createWallet = "\(prefix)createWallet"
            static let login = "\(prefix)login"
            static let recoverFunds = "\(prefix)recoverFunds"
        }
    }
}
