// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

final class ContextProvider: ContextProviderAPI {

    private let guidProvider: GuidProviderAPI
    private let timeZone: TimeZone
    private let locale: Locale

    init(guidProvider: GuidProviderAPI,
         timeZone: TimeZone = .current,
         locale: Locale = .current) {
        self.guidProvider = guidProvider
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
        guidProvider.guid
    }
}
