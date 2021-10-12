// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum StaticFeatureFlags {

    private enum UserDefaultsKeys {
        static let dynamicAssetsEnabledKey = "StaticFeatureFlags.UserDefaultsKeys.dynamicAssetsEnabledKey"
    }

    public static var isDynamicAssetsEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: UserDefaultsKeys.dynamicAssetsEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.dynamicAssetsEnabledKey)
        }
    }
}
