// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol ForgetWalletAPI {
    func forget()
}

final class ForgetWallet: ForgetWalletAPI {

    let walletRepo: WalletRepoAPI
    let walletState: WalletHolderAPI

    init(
        walletRepo: WalletRepoAPI,
        walletState: WalletHolderAPI
    ) {
        self.walletRepo = walletRepo
        self.walletState = walletState
    }

    func forget() {
        walletRepo.set(value: .empty)
        walletState.release()
    }
}
