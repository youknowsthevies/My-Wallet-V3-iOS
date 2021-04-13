//
//  StellarAddress.swift
//  StellarKit
//
//  Created by Paulo on 21/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

struct StellarReceiveAddress: CryptoReceiveAddress, CryptoAssetQRMetadataProviding {
    let asset: CryptoCurrency = .stellar
    let address: String
    let label: String
    let memo: String?
    let onTxCompleted: (TransactionResult) -> Completable

    var metadata: CryptoAssetQRMetadata {
        StellarURLPayload(address: address, amount: nil)
    }

    init(address: String,
         label: String,
         memo: String? = nil,
         onTxCompleted: @escaping (TransactionResult) -> Completable = { _ in .empty() }) {
        self.address = address
        self.label = label
        self.memo = memo
        self.onTxCompleted = onTxCompleted
    }
}
