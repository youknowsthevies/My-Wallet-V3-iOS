// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Foundation
import SettingsKit

final class GuidProvider: GuidProviderAPI {

    private let settings: BlockchainSettings.App

    init(settings: BlockchainSettings.App = resolve()) {
        self.settings = settings
    }

    var guid: String? {
        settings.guid
    }
}
