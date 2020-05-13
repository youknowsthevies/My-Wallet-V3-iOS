//
//  WalletFiatAtTime.swift
//  Blockchain
//
//  Created by kevinwu on 5/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

@objc protocol WalletFiatAtTimeDelegate: class {

    /// Method invoked after getting fiat at time
    func didGetFiatAtTime(fiatAmount: NSDecimalNumber, currencyCode: String, assetType: LegacyAssetType)

    /// Method invoked when an error occurs while getting fiat at time
    func didErrorWhenGettingFiatAtTime(error: String?)
}

@objc protocol WalletFiatAtTimeAPI {
    var delegate: WalletFiatAtTimeDelegate? { get set }
    func getFiatAtTime(_ timestamp: UInt64, value: NSDecimalNumber, currencyCode: String, assetType: LegacyAssetType)
}

class WalletFiatAtTime: NSObject, WalletFiatAtTimeAPI {
    @objc static let shared: WalletFiatAtTimeAPI = WalletFiatAtTime()

    private let priceService = PriceService()
    @objc weak var delegate: WalletFiatAtTimeDelegate?
    private let disposeBag = DisposeBag()

    @objc func getFiatAtTime(_ timestamp: UInt64, value: NSDecimalNumber, currencyCode: String, assetType: LegacyAssetType) {
        let cryptoCurrency = CryptoCurrency(legacyAssetType: assetType)
        let fiatCurrency = FiatCurrency(code: currencyCode)!
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        priceService
            .price(for: cryptoCurrency, in: fiatCurrency, at: date)
            .subscribe(
                onSuccess: { [weak self] priceInFiatValue in
                    let resultValue = NSDecimalNumber(decimal: priceInFiatValue.priceInFiat.amount).multiplying(by: value)
                    self?.delegate?.didGetFiatAtTime(fiatAmount: resultValue, currencyCode: currencyCode, assetType: assetType)
                },
                onError: { [weak self] error in
                    self?.delegate?.didErrorWhenGettingFiatAtTime(error: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
