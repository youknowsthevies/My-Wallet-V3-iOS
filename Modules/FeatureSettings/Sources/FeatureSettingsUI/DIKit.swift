// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformUIKit
import ToolKit

extension DependencyContainer {

    public static var featureSettingsUI = module {

        single { SettingsRouter() as SettingsRouterAPI }
    }
}
