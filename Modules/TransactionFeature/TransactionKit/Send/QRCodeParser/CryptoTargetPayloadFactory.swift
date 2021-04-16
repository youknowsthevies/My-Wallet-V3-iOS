//
//  CryptoTargetPayloadFactory.swift
//  TransactionKit
//
//  Created by Alex McGregor on 4/9/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift

final class CryptoTargetPayloadFactory: CryptoTargetPayloadFactoryAPI {
    
    // MARK: - Enums
    
    private enum CryptoTargetPayloadError: Error {
        case invalidStringData
    }
    
    // MARK: - Private Properties
    
    private let assetPayloadFactory: AssetURLPayloadFactoryAPI
    
    // MARK: - Init
    
    init(assetPayloadFactory: AssetURLPayloadFactoryAPI = resolve()) {
        self.assetPayloadFactory = assetPayloadFactory
    }
    
    // MARK: - CryptoTargetPayloadFactoryAPI
    
    func create(fromString string: String?, asset: CryptoCurrency) -> Single<CryptoTargetQRCodeParser.Target> {
        guard let data = string else { return .error(CryptoTargetPayloadError.invalidStringData) }
        let metadata = makeCryptoQRMetaData(fromString: data, asset: asset)
        guard asset.supportsBitPay else {
            return metadata
        }
        return BitPayInvoiceTarget
            .isValidBitPay(data)
            .andThen(Single.just(.bitpay(data)))
            .catchError { _ in metadata }
    }
    
    // MARK: - Private Functions
    
    private func makeCryptoQRMetaData(fromString string: String?, asset: CryptoCurrency) -> Single<CryptoTargetQRCodeParser.Target> {
        Single.create(weak: self) { (self, observer) -> Disposable in
            guard let metadata = self.assetPayloadFactory.create(fromString: string, asset: asset) else {
                observer(.error(CryptoTargetPayloadError.invalidStringData))
                return Disposables.create()
            }
            observer(.success(.metadata(metadata)))
            return Disposables.create()
        }
    }
}
