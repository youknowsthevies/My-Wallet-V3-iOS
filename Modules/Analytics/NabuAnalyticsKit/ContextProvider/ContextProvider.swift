// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

class ContextProvider: ContextProviding {
    
    var context: Context {
        return Context(
            app: App(),
            device: Device(),
            locale: locale,
            screen: Screen(),
            timezone: timezone
        )
    }
    
    private var locale: String {
        return [Locale.current.regionCode, Locale.current.languageCode]
            .compactMap { $0 }
            .joined(separator: "_")
    }
    
    private var timezone: String? {
        return TimeZone.current.localizedName(for: .shortStandard, locale: Locale.current)
    }
    
    var anonymousId: String = ""
}
