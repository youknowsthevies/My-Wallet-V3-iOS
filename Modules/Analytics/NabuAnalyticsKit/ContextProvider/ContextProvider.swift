// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import SettingsKit

final class ContextProvider: ContextProviderAPI {

    private let settings: BlockchainSettings.App
    private let timeZone: TimeZone
    private let locale: Locale

    init(settings: BlockchainSettings.App = resolve(),
         timeZone: TimeZone = .current,
         locale: Locale = .current) {
        self.settings = settings
        self.timeZone = timeZone
        self.locale = locale
    }

    var context: Context {
        let localeString = [locale.languageCode, locale.regionCode]
            .compactMap { $0 }
            .joined(separator: "-")
        let timeZoneString = timeZone.localizedName(for: .shortStandard, locale: locale)
        return Context(
            app: App(),
            device: Device(),
            os: OperatingSystem(),
            locale: localeString,
            screen: Screen(),
            timezone: timeZoneString
        )
    }

    var anonymousId: String? {
        settings.guid
    }
}
