// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import WalletPayloadKit

public struct ForgetWalletService {
    public var forget: () -> Void
}

extension ForgetWalletService {
    public static func live(
        forgetWallet: ForgetWalletAPI
    ) -> ForgetWalletService {
        ForgetWalletService(
            forget: {
                forgetWallet.forget()
            }
        )
    }
}
