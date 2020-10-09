//
//  CryptoAssetQRMetadataBridge.swift
//  Blockchain
//
//  Created by Paulo on 24/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import AVFoundation
import PlatformKit

/// Bridges CryptoAssetQRMetadata for SendBitcoinViewController.
@objc class CryptoAssetQRMetadataBridge: NSObject {

    @objc var paymentRequestUrl: String? {
        metadata?.paymentRequestUrl
    }

    @objc var address: String? {
        metadata?.address
    }

    @objc var amount: String? {
        metadata?.amount
    }

    @objc func isAsset(_ asset: LegacyAssetType) -> Bool {
        metadata?.cryptoCurrency.legacy == asset
    }

    @objc var assetName: String? {
        metadata?.cryptoCurrency.name
    }

    let metadata: CryptoAssetQRMetadata?

    @objc init(metadata: AVMetadataMachineReadableCodeObject, assetType: LegacyAssetType) {
        self.metadata = AssetURLPayloadFactory.create(fromString: metadata.stringValue, asset: CryptoCurrency(legacyAssetType: assetType))
        super.init()
    }
}
