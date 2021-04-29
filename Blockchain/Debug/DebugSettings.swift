// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

@objc
class DebugSettings: NSObject {
    static let shared = DebugSettings()

    @objc class func sharedInstance() -> DebugSettings {
        shared
    }

    @objc var createWalletPrefill: Bool {
        get {
            defaults.bool(forKey: UserDefaults.DebugKeys.createWalletPrefill.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.DebugKeys.createWalletPrefill.rawValue)
        }
    }

    @objc var createWalletEmailPrefill: String {
        get {
            let prefill = defaults.object(forKey: UserDefaults.DebugKeys.createWalletEmailPrefill.rawValue) as? String
            guard let unwrappedPrefill = prefill, unwrappedPrefill.count > 0 else {
                return "test@doesnotexist.com"
            }
            return unwrappedPrefill
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.DebugKeys.createWalletEmailPrefill.rawValue)
        }
    }

    @objc var createWalletEmailRandomSuffix: Bool {
        get {
            defaults.bool(forKey: UserDefaults.DebugKeys.createWalletEmailRandomSuffix.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.DebugKeys.createWalletEmailRandomSuffix.rawValue)
        }
    }

    @objc var useHomebrewForExchange: Bool {
        get {
            defaults.bool(forKey: UserDefaults.DebugKeys.useHomebrewForExchange.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.DebugKeys.useHomebrewForExchange.rawValue)
        }
    }

    @objc var mockExchangeOrderDepositAddress: String? {
        get {
            defaults.object(forKey: UserDefaults.DebugKeys.mockExchangeOrderDepositAddress.rawValue) as? String
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.DebugKeys.mockExchangeOrderDepositAddress.rawValue)
        }
    }

    @objc var mockExchangeDeposit: Bool {
        get {
            defaults.bool(forKey: UserDefaults.DebugKeys.mockExchangeDeposit.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.DebugKeys.mockExchangeDeposit.rawValue)
        }
    }

    @objc var mockExchangeDepositQuantity: String? {
        get {
            defaults.object(forKey: UserDefaults.DebugKeys.mockExchangeDepositQuantity.rawValue) as? String
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.DebugKeys.mockExchangeDepositQuantity.rawValue)
        }
    }

    var mockExchangeDepositAssetTypeString: String? {
        get {
            defaults.object(forKey: UserDefaults.DebugKeys.mockExchangeDepositAssetTypeString.rawValue) as? String
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.DebugKeys.mockExchangeDepositAssetTypeString.rawValue)
        }
    }

    @LazyInject private var defaults: CacheSuite

    private override init() { }
}
