// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

/// Helper to convert between CryptoCurrency <-> LegacyAssetType.
// To be deprecated once LegacyAssetType has been removed.
@objc class AssetTypeLegacyHelper: NSObject {

    @objc
    static func displayCode(for type: LegacyAssetType) -> String {
        CryptoCurrency(legacyAssetType: type).displayCode
    }
}
