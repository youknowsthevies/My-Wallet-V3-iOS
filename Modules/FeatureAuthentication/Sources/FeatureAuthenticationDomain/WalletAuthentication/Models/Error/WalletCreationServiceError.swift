// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import WalletPayloadKit

public enum WalletCreationServiceError: Error, Equatable {
    case creationFailure(WalletCreateError)
}
