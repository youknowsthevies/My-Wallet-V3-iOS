// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import PlatformKit

extension DependencyContainer {

    // MARK: - PlatformKit Module

    public static var platformDataKit = module {

        // MARK: - Price

        factory { PriceClient() as PriceClientAPI }

        single { PriceRepository() as PriceRepositoryAPI }
    }
}
