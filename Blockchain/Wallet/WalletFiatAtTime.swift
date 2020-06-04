//
//  WalletFiatAtTime.swift
//  Blockchain
//
//  Created by kevinwu on 5/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import ToolKit

@objc protocol WalletFiatAtTimeDelegate: class {

    /// Method invoked after getting fiat at time
    func didGetFiatAtTime(fiatAmount: NSDecimalNumber, currencyCode: String, assetType: LegacyAssetType)

    /// Method invoked when an error occurs while getting fiat at time
    func didErrorWhenGettingFiatAtTime(error: String?)
}

@objc protocol WalletFiatAtTimeAPI {
    var delegate: WalletFiatAtTimeDelegate? { get set }
    func getFiatAtTime(_ timestamp: UInt64, value: NSDecimalNumber, currencyCode: String?, assetType: LegacyAssetType)
}

final class WalletFiatAtTime: NSObject, WalletFiatAtTimeAPI {

    @objc static let shared: WalletFiatAtTimeAPI = WalletFiatAtTime()

    private let priceService: PriceService
    private let errorRecorder: ErrorRecording
    private let disposeBag = DisposeBag()

    @objc weak var delegate: WalletFiatAtTimeDelegate?

    private init(priceService: PriceService = PriceService(), errorRecorder: ErrorRecording = CrashlyticsRecorder()) {
        self.priceService = priceService
        self.errorRecorder = errorRecorder
    }

    private enum WalletFiatAtTimeError: Error {
        case invalidCurrencyCode(String?)

        var localizedDescription: String {
            switch self {
            case .invalidCurrencyCode(let code):
                return "Invalid currency code: \(code ?? "nil")"
            }
        }
    }

    private func getFiat(at date: Date, value: NSDecimalNumber, fiatCurrency: FiatCurrency, cryptoCurrency: CryptoCurrency) {
        priceService
            .price(for: cryptoCurrency, in: fiatCurrency, at: date)
            .subscribe(
                onSuccess: { [weak self] priceInFiatValue in
                    let resultValue = NSDecimalNumber(decimal: priceInFiatValue.priceInFiat.amount).multiplying(by: value)
                    self?.delegate?.didGetFiatAtTime(fiatAmount: resultValue, currencyCode: fiatCurrency.code, assetType: cryptoCurrency.legacy)
                },
                onError: { [weak self] error in
                    self?.delegate?.didErrorWhenGettingFiatAtTime(error: error.localizedDescription)
                }
        )
            .disposed(by: disposeBag)
    }

    @objc func getFiatAtTime(_ timestamp: UInt64, value: NSDecimalNumber, currencyCode: String?, assetType: LegacyAssetType) {
        guard
            let validCurrencyCode = currencyCode,
            let fiatCurrency = FiatCurrency(code: validCurrencyCode) else {
                let error = WalletFiatAtTimeError.invalidCurrencyCode(currencyCode)
                errorRecorder.error(error)
                return
        }
        getFiat(
            at: Date(timeIntervalSince1970: TimeInterval(timestamp)),
            value: value,
            fiatCurrency: fiatCurrency,
            cryptoCurrency: CryptoCurrency(legacyAssetType: assetType)
        )
    }
}
