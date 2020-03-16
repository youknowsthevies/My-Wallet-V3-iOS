//
//  BitpayAnalyticsEvent.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/3/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit

// MARK: - Deprecate these once we SendBitcoinViewController is written in Swift

@objc class BitpayUrlScanned: NSObject, ObjcAnalyticsEvent {
    private let asset: CryptoCurrency

    private var event: AnalyticsEvent {
        return AnalyticsEvents.Bitpay.bitpayUrlScanned(asset: asset)
    }

    @objc class func create(legacyAssetType: LegacyAssetType) -> BitpayUrlScanned {
        return BitpayUrlScanned(asset: legacyAssetType)
    }

    init(asset: LegacyAssetType) {
        self.asset = CryptoCurrency(legacyAssetType: asset)
    }

    var name: String {
        return event.name
    }

    var params: [String : String]? {
        return event.params
    }
}

@objc class BitpayUrlPasted: NSObject, ObjcAnalyticsEvent {
    private let asset: CryptoCurrency

    private var event: AnalyticsEvent {
        return AnalyticsEvents.Bitpay.bitpayUrlPasted(asset: asset)
    }

    @objc class func create(legacyAssetType: LegacyAssetType) -> BitpayUrlPasted {
        return BitpayUrlPasted(asset: legacyAssetType)
    }

    init(asset: LegacyAssetType) {
        self.asset = CryptoCurrency(legacyAssetType: asset)
    }

    var name: String {
        return event.name
    }

    var params: [String : String]? {
        return event.params
    }
}

@objc class BitpayPaymentExpired: NSObject, ObjcAnalyticsEvent {
    var name: String {
        return AnalyticsEvents.Bitpay.bitpayPaymentExpired.name
    }

    var params: [String : String]? {
        return AnalyticsEvents.Bitpay.bitpayPaymentExpired.params
    }
}
