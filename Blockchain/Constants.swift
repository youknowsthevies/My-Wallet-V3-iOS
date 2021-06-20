// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

struct Constants {

    static let commitHash = "COMMIT_HASH"

    struct Conversions {
        // SATOSHI = 1e8 (100,000,000)
        static let satoshi = Double(1e8)
    }

    struct AppStore {
        static let AppID = "id493253309"
    }
    struct Animation {
        static let duration = 0.2
    }
    struct Navigation {
        static let tabTransactions = 0
        static let tabSwap = 1
        static let tabDashboard = 2
        static let tabSend = 3
        static let tabReceive = 4
    }
    struct Measurements {
        static let DefaultHeaderHeight: CGFloat = 65
        // TODO: remove this once we use autolayout
        static let DefaultNavigationBarHeight: CGFloat = 44.0
        static let DefaultTabBarHeight: CGFloat = 49.0
        static let AssetSelectorHeight: CGFloat = 36.0
        static let ScreenHeightIphone5S: CGFloat = 568.0
        static let buttonCornerRadius: CGFloat = 4.0
        static let assetTypeCellHeight: CGFloat = 44.0
    }
    struct FontSizes {
        static let ExtraExtraExtraSmall: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 13.0 : 11.0
        static let Small: CGFloat = Booleans.IsUsingScreenSizeLargerThan5s ? 16.0 : 13.0
    }
    struct FontNames {
        static let montserratRegular = "Montserrat-Regular"
        static let montserratSemiBold = "Montserrat-SemiBold"
    }
    struct Booleans {
        static let isUsingScreenSizeEqualIphone5S = UIScreen.main.bounds.size.height == Measurements.ScreenHeightIphone5S
        static let IsUsingScreenSizeLargerThan5s = UIScreen.main.bounds.size.height > Measurements.ScreenHeightIphone5S
    }
    struct NotificationKeys {
        static let modalViewDismissed = NSNotification.Name("modalViewDismissed")
        static let reloadToDismissViews = NSNotification.Name("reloadToDismissViews")
        static let newAddress = NSNotification.Name("newAddress")
        static let multiAddressResponseReload = NSNotification.Name("multiaddressResponseReload")
        static let appEnteredBackground = NSNotification.Name("applicationDidEnterBackground")
        static let backupSuccess = NSNotification.Name("backupSuccess")
        static let getFiatAtTime = NSNotification.Name("getFiatAtTime")
        static let exchangeSubmitted = NSNotification.Name("exchangeSubmitted")
        static let kycStopped = NSNotification.Name("kycStopped")
        static let swapFlowCompleted = NSNotification.Name("swapFlowCompleted")
        static let swapToPaxFlowCompleted = NSNotification.Name("swapToPaxFlowCompleted")
    }
    struct PushNotificationKeys {
        static let userInfoType = "type"
        static let userInfoId = "id"
        static let typePayment = "payment"
    }
    struct Url {
        static let withdrawalLockArticle = "https://support.blockchain.com/hc/en-us/articles/360048200392"
        static let blockchainHome = "https://www.blockchain.com"
        static let privacyPolicy = blockchainHome + "/privacy"
        static let cookiesPolicy = blockchainHome + "/legal/cookies"
        static let termsOfService = blockchainHome + "/terms"

        static let appStoreLinkPrefix = "itms-apps://itunes.apple.com/app/"
        static let blockchainSupport = "https://support.blockchain.com"
        static let exchangeSupport = "https://exchange-support.blockchain.com/hc/en-us"
        static let forgotPassword = "https://support.blockchain.com/hc/en-us/articles/211205343-I-forgot-my-password-What-can-you-do-to-help-"
        static let blockchainWalletLogin = "https://login.blockchain.com"
        static let lockbox = "https://blockchain.com/lockbox"
        static let stellarMinimumBalanceInfo = "https://www.stellar.org/developers/guides/concepts/fees.html#minimum-account-balance"
        static let ethGasExplanationForPax = "https://support.blockchain.com/hc/en-us/articles/360027492092-Why-do-I-need-ETH-to-send-my-PAX-"
    }
    struct JSErrors {
        static let addressAndKeyImportWrongBipPass = "wrongBipPass"
        static let addressAndKeyImportWrongPrivateKey = "wrongPrivateKey"
    }
    struct FilterIndexes {
        static let all: Int32 = -1
        static let importedAddresses: Int32 = -2
    }
}

/// Constant class wrapper so that Constants can be accessed from Obj-C. Should deprecate this
/// once Obj-C is no longer using this
@objc class ConstantsObjcBridge: NSObject {
    @objc class func notificationKeyReloadToDismissViews() -> String {
        Constants.NotificationKeys.reloadToDismissViews.rawValue
    }

    @objc class func notificationKeyNewAddress() -> String {
        Constants.NotificationKeys.newAddress.rawValue
    }

    @objc class func notificationKeyMultiAddressResponseReload() -> String {
        Constants.NotificationKeys.multiAddressResponseReload.rawValue
    }

    @objc class func notificationKeyBackupSuccess() -> String {
        Constants.NotificationKeys.backupSuccess.rawValue
    }

    @objc class func filterIndexAll() -> Int32 {
        Constants.FilterIndexes.all
    }

    @objc class func filterIndexImportedAddresses() -> Int32 {
        Constants.FilterIndexes.importedAddresses
    }

    @objc class func assetTypeCellHeight() -> CGFloat {
        Constants.Measurements.assetTypeCellHeight
    }

    @objc class func bitcoinCashUriPrefix() -> String {
        AssetConstants.URLSchemes.bitcoinCash
    }

    @objc class func defaultNavigationBarHeight() -> CGFloat {
        Constants.Measurements.DefaultNavigationBarHeight
    }

    @objc class func assetSelectorHeight() -> CGFloat {
        Constants.Measurements.AssetSelectorHeight
    }
}
