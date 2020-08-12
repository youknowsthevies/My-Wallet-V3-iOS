//
//  KYCSettings.swift
//  Blockchain
//
//  Created by kevinwu on 12/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import ToolKit

@objc
class KYCSettings: NSObject, KYCSettingsAPI {
    static let shared = KYCSettings()

    private let cacheSuite: CacheSuite

    @objc class func sharedInstance() -> KYCSettings {
        shared
    }

    init(cacheSuite: CacheSuite = resolve()) {
        self.cacheSuite = cacheSuite
    }

    /**
     Determines if the user is currently completing the KYC process. This allow the application to determine
     if it should show the *Continue verification* announcement card on the dashboard.

     - Note:
     This value is set to `true` whenever the user taps on the primary button on the KYC welcome screen.

     This value is set to `false` whenever the *Application complete* screen in the KYC flow will disappear.

     - Important:
     This setting **MUST** be set to `false` upon logging the user out of the application.
     */
    @objc var isCompletingKyc: Bool {
        get {
            cacheSuite.bool(forKey: UserDefaults.Keys.isCompletingKyc.rawValue)
        }
        set {
            cacheSuite.set(newValue, forKey: UserDefaults.Keys.isCompletingKyc.rawValue)
        }
    }

    var latestKycPage: KYCPageType? {
        get {
            let page = cacheSuite.integer(forKey: UserDefaults.Keys.kycLatestPage.rawValue)
            return KYCPageType(rawValue: page)
        }
        set {
            if newValue == nil {
                cacheSuite.set(nil, forKey: UserDefaults.Keys.kycLatestPage.rawValue)
                return
            }

            let previousPage = cacheSuite.integer(forKey: UserDefaults.Keys.kycLatestPage.rawValue)
            guard let newPage = newValue, previousPage < newPage.rawValue else {
                Logger.shared.warning("\(newValue?.rawValue ?? 0) is not less than \(previousPage) for 'latestKycPage'.")
                return
            }
            cacheSuite.set(newPage.rawValue, forKey: UserDefaults.Keys.kycLatestPage.rawValue)
        }
    }

    func reset() {
        latestKycPage = nil
        isCompletingKyc = false
    }
}
