// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit

public enum EthereumKitValidationError: Error {
    case noGasPrice
    case noGasLimit
    case unknown
}
