// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

/// Content the represents an address on the data level
struct WalletAddressContent {

    /// The string representing the address
    let string: String

    /// The image representing the QR code of the address
    let qrCode: QRCodeAPI
}
