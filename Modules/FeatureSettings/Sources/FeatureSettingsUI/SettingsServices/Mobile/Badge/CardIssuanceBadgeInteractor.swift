// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class CardIssuanceBadgeInteractor: DefaultBadgeAssetInteractor {

    init(service: SettingsServiceAPI) {
        super.init()
        stateRelay.accept(.loaded(next: .orderCard))
    }
}
