// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxRelay

protocol SettingsRouterAPI: RoutingPreviousStateEmitterAPI {
    var actionRelay: PublishRelay<SettingsScreenAction> { get }
    func presentSettings()
}
