// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureQRCodeScannerUI
@testable import PlatformUIKit

final class MockQRScannableArea: QRCodeScannableArea {
    var area: CGRect = .zero
}
