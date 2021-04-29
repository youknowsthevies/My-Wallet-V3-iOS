// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

public protocol LinkedBanksFactoryAPI {
    var linkedBanks: Single<[LinkedBankAccount]> { get }
    var nonWireTransferBanks: Single<[LinkedBankAccount]> { get }
}

final class LinkedBanksFactory: LinkedBanksFactoryAPI {
    
    /// TODO: Inject `LinkedBanksServiceAPI` once moved to `PlatformKit`
    
    var linkedBanks: Single<[LinkedBankAccount]> {
        unimplemented()
    }
    
    var nonWireTransferBanks: Single<[LinkedBankAccount]> {
        unimplemented()
    }
}
