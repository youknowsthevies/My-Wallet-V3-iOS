// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import PlatformKit

// MARK: - Deprecate these once we SendBitcoinViewController is written in Swift

@objc class BitpayUrlScanned: NSObject, ObjcAnalyticsEvent {
    private let asset: CryptoCurrency

    private var event: AnalyticsEvent {
        AnalyticsEvents.Bitpay.bitpayUrlScanned(asset: asset)
    }

    @objc class func create(legacyAssetType: LegacyAssetType) -> BitpayUrlScanned {
        BitpayUrlScanned(asset: legacyAssetType)
    }

    init(asset: LegacyAssetType) {
        self.asset = CryptoCurrency(legacyAssetType: asset)
    }

    var name: String {
        event.name
    }

    var params: [String : String]? {
        event.params
    }
}

@objc class BitpayUrlPasted: NSObject, ObjcAnalyticsEvent {
    private let asset: CryptoCurrency

    private var event: AnalyticsEvent {
        AnalyticsEvents.Bitpay.bitpayUrlPasted(asset: asset)
    }

    @objc class func create(legacyAssetType: LegacyAssetType) -> BitpayUrlPasted {
        BitpayUrlPasted(asset: legacyAssetType)
    }

    init(asset: LegacyAssetType) {
        self.asset = CryptoCurrency(legacyAssetType: asset)
    }

    var name: String {
        event.name
    }

    var params: [String : String]? {
        event.params
    }
}

@objc class BitpayPaymentExpired: NSObject, ObjcAnalyticsEvent {
    var name: String {
        AnalyticsEvents.Bitpay.bitpayPaymentExpired.name
    }

    var params: [String : String]? {
        AnalyticsEvents.Bitpay.bitpayPaymentExpired.params
    }
}
