// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol OnboardingSettingsAPI {
    var walletIntroLatestLocation: WalletIntroductionLocation? { get set }
    var firstRun: Bool { get set }

    func reset()
}

/// Encapsulates all onboarding-related settings for the user
final class OnboardingSettings: OnboardingSettingsAPI {

    private lazy var defaults: UserDefaults = .standard

    var walletIntroLatestLocation: WalletIntroductionLocation? {
        get {
            let value = defaults.object(forKey: UserDefaults.Keys.walletIntroLatestLocation.rawValue)
            guard let value = value as? Data else {
                return nil
            }
            return try? JSONDecoder().decode(WalletIntroductionLocation.self, from: value)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.Keys.walletIntroLatestLocation.rawValue)
        }
    }

    /**
     Determines if this is the first time the user is running the application.

     - Note:
     This value is set to `true` if the application is running for the first time.

     This setting is currently not used for anything else.
     */
    var firstRun: Bool {
        get {
            defaults.bool(forKey: UserDefaults.Keys.firstRun.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.Keys.firstRun.rawValue)
        }
    }

    func reset() {
        walletIntroLatestLocation = nil
    }
}
