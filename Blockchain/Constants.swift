// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

enum Constants {

    static let commitHash = "COMMIT_HASH"

    enum Conversions {
        // SATOSHI = 1e8 (100,000,000)
        static let satoshi = Double(1e8)
    }

    enum AppStore {
        static let AppID = "id493253309"
    }
    enum Animation {
        static let duration = 0.2
    }
    enum Navigation {
        static let tabTransactions = 0
        static let tabSwap = 1
        static let tabDashboard = 2
        static let tabSend = 3
        static let tabReceive = 4
    }
    enum Measurements {
        static let DefaultHeaderHeight: CGFloat = 65
        static let DefaultNavigationBarHeight: CGFloat = 44.0
        static let AssetSelectorHeight: CGFloat = 44.0
        static let ScreenHeightIphone5S: CGFloat = 568.0
    }
    enum FontSizes {
        static let ExtraExtraExtraSmall: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 13.0 : 11.0
        static let Small: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 16.0 : 13.0
    }
    enum FontNames {
        static let montserratRegular = "Montserrat-Regular"
        static let montserratSemiBold = "Montserrat-SemiBold"
    }
    enum Booleans {
        static let isUsingScreenSizeEqualIphone5S = UIScreen.main.bounds.size.height == Measurements.ScreenHeightIphone5S
        static let IsUsingScreenSizeLargerThan5s = UIScreen.main.bounds.size.height > Measurements.ScreenHeightIphone5S
    }
    enum NotificationKeys {
        static let backupSuccess = NSNotification.Name("backupSuccess")
        static let kycStopped = NSNotification.Name("kycStopped")
    }
    enum Url {
        static let blockchainHome = "https://www.blockchain.com"
        static let privacyPolicy = blockchainHome + "/privacy"
        static let termsOfService = blockchainHome + "/terms"
        static let appStoreLinkPrefix = "itms-apps://itunes.apple.com/app/"
        static let blockchainSupport = "https://support.blockchain.com"
        static let forgotPassword = "https://support.blockchain.com/hc/en-us/articles/211205343-I-forgot-my-password-What-can-you-do-to-help-"
        static let blockchainWalletLogin = "https://login.blockchain.com"
        static let lockbox = "https://blockchain.com/lockbox"
    }
}

/// Constant class wrapper so that Constants can be accessed from Obj-C. Should deprecate this
/// once Obj-C is no longer using this
@objc final class ConstantsObjcBridge: NSObject {
    @objc class func notificationKeyBackupSuccess() -> String {
        Constants.NotificationKeys.backupSuccess.rawValue
    }

    @objc class func defaultNavigationBarHeight() -> CGFloat {
        Constants.Measurements.DefaultNavigationBarHeight
    }

    @objc class func assetSelectorHeight() -> CGFloat {
        Constants.Measurements.AssetSelectorHeight
    }
}
