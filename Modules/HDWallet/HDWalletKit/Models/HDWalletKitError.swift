// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum HDWalletKitError: Error {
    case unknown
    case libWallyError(Error)
}
