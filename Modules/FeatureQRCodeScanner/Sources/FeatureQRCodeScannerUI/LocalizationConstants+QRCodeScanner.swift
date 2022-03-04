// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    enum QRCodeScanner {
        static let connectedDapps = NSLocalizedString(
            "%@ Connected Apps",
            comment: "Number of connected dApps with WalletConnect"
        )

        static let connectedDApp = NSLocalizedString(
            "1 Connected App",
            comment: "When only 1 connected dApp with WalletConnect"
        )

        enum AllowAccessScreen {
            static let title = NSLocalizedString(
                "Scan & Connect",
                comment: "Allow Screen: main title"
            )

            static let buttonTitle = NSLocalizedString(
                "Allow Camera Access",
                comment: "Allow Screen: button click to action title"
            )

            enum ScanQRPoint {
                static let title = NSLocalizedString(
                    "Scan a Friend’s QR Code",
                    comment: "Scan a Friend’s QR Code title"
                )
                static let description = NSLocalizedString(
                    "Point your phone at a friend’s QR code and we’ll paste the address.",
                    comment: "Scan a Friend’s QR Code description"
                )
            }

            enum AccessWebWallet {
                static let title = NSLocalizedString(
                    "Access Your Wallet on the Web",
                    comment: "Access Your Wallet on the Web title"
                )
                static let description = NSLocalizedString(
                    "Logging in blockchain.com? Scan the code with your phone to log in.",
                    comment: "Access Your Wallet on the Web description"
                )
            }

            enum ConnectToDapps {
                static let title = NSLocalizedString(
                    "Connect to Dapps",
                    comment: "Connect to Dapps title"
                )
                static let description = NSLocalizedString(
                    "Securely connect your wallet to any web 3.0 application. Learn more",
                    comment: "Connect to Dapps description"
                )
                static let betaTagTitle = NSLocalizedString(
                    "BETA",
                    comment: "Connect to Dapps beta tag title"
                )
            }
        }
    }
}
