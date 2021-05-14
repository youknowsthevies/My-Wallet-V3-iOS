// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DashboardUIKit
import DIKit
import ToolKit

public extension DependencyContainer {

    static var settingsUIKit = module {

        factory { BackupFundsCustodialRouter() as DashboardBackupRouterAPI }
    }
}
