// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformUIKit
import ToolKit

extension DependencyContainer {

    public static var settingsUIKit = module {

        factory { SettingsRouter() as SettingsRouterAPI }
    }
}
