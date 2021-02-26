//
//  MockQRScannableArea.swift
//  TransactionUIKitTests
//
//  Created by Paulo on 25/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import PlatformUIKit

final class MockQRScannableArea: QRCodeScannableArea {
    var area: CGRect = .zero
}
