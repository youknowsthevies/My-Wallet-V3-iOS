// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public enum QRCodeParserTarget {
    case address(CryptoAccount, CryptoReceiveAddress)
    case bitpay(String)
}
