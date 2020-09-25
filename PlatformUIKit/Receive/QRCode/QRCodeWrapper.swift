//
//  QRCodeWrapper.swift
//  PlatformUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 23/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol QRCodeWrapperAPI {
    func qrCode(from metadata: CryptoAssetQRMetadata) -> QRCodeAPI?
    func qrCode(from string: String) -> QRCodeAPI?
}
