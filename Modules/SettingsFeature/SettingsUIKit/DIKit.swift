// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformUIKit
import ToolKit

public extension DependencyContainer {

    static var settingsUIKit = module {

        factory { SettingsRouter() as SettingsRouterAPI }
    }
}
