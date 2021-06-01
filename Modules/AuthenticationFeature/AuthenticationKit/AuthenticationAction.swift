// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum AuthenticationAction: Equatable {
    case createWallet
    case login
    case recoverFunds

    case setLoginVisible(Bool)
}
