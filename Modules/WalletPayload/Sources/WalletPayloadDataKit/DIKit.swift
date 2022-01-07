// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import WalletPayloadKit

extension DependencyContainer {

    // MARK: - walletPayloadDataKit Module

    public static var walletPayloadDataKit = module {

        factory { WalletPayloadClient() as WalletPayloadClientAPI }

        factory { WalletPayloadRepository() as WalletPayloadRepositoryAPI }

        factory { () -> WalletCreatorAPI in
            WalletCreator() as WalletCreatorAPI
        }

        factory { () -> ReleasableWalletAPI in
            let holder: WalletHolder = DIKit.resolve()
            return holder as ReleasableWalletAPI
        }

        factory { () -> WalletHolderAPI in
            let holder: WalletHolder = DIKit.resolve()
            return holder as WalletHolderAPI
        }

        single { WalletHolder() }
    }
}
