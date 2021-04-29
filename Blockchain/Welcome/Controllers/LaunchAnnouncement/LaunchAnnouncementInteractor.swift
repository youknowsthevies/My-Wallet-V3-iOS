// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

final class LaunchAnnouncementInteractor {

    // MARK: - Exposed Properties
    
    /// Streams an `UpdateType` element
    var updateType: Single<LaunchAnnouncementType> {
        walletOptionsAPI.walletOptions
            .observeOn(MainScheduler.instance)
            .map { options in
                if options.downForMaintenance {
                    return .maintenance(options)
                } else if UIDevice.current.isUnsafe() {
                    return .jailbrokenWarning
                } else {
                    return .updateIfNeeded(options.updateType)
                }
            }
    }
    
    private let walletOptionsAPI: WalletOptionsAPI
    
    // MARK: - Setup
    
    init(walletOptionsAPI: WalletOptionsAPI = resolve()) {
        self.walletOptionsAPI = walletOptionsAPI
    }
}
