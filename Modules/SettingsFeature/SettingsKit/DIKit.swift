// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import ToolKit

public extension DependencyContainer {

    static var settingsKit = module {

        factory { PITConnectionStatusProvider() as PITConnectionStatusProviding }

        factory { TierLimitsProvider() as TierLimitsProviding }

    }

}
