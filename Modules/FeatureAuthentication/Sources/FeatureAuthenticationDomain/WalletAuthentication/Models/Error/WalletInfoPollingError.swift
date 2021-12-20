// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum WalletInfoPollingError: Error, Equatable {
    case continuePolling
    case requestDenied
}
