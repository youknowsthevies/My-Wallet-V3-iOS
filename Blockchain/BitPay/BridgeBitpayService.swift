// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import NetworkKit
import PlatformKit
import RxSwift

enum BridgeBitpayServiceError: Error {
    case invalidTransactionSize
}

/// Bridging layer for Swift-ObjC, since ObjC isn't compatible with RxSwift
@objc
class BridgeBitpayService: NSObject {
    
    // MARK: - Properties
    
    private let bitpayService: BitpayServiceProtocol
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(bitpayService: BitpayServiceProtocol = BitpayService()) {
        self.bitpayService = bitpayService
        super.init()
    }

    override init() {
        self.bitpayService = BitpayService()
        super.init()
    }
    
    @objc func bitpayPaymentRequest(invoiceID: String,
                                    assetType: LegacyAssetType,
                                    completion: @escaping (ObjcCompatibleBitpayObject?, String?) -> Void) {
        // TICKET: IOS-2498 - Support BCH
        let currency: CryptoCurrency = CryptoCurrency(legacyAssetType: assetType)
        guard currency == .bitcoin else {
            completion(nil, "Only Bitcoin payments are supported")
            return
        }

        bitpayService
            .bitpayPaymentRequest(
                invoiceID: invoiceID,
                currency: currency
            )
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { bitpayModel in
                    completion(bitpayModel, nil)
                },
                onError: { error in
                    let message: String
                    switch error {
                    case NetworkError.payloadError(.badData(rawPayload: let payload)):
                        message = payload
                    default:
                        message = error.localizedDescription
                    }
                    completion(nil, message)
                }
            )
            .disposed(by: disposeBag)
    }
    
    // TICKET: IOS-2498 - Support BCH
    @objc func verifyAndPostSignedTransaction(invoiceID: String,
                                              assetType: LegacyAssetType,
                                              transactionHex: String,
                                              transactionSize: String,
                                              completion: @escaping (String?, Error?) -> Void) {
        guard let size = Int(transactionSize) else {
            completion(nil, BridgeBitpayServiceError.invalidTransactionSize)
            return
        }
        let currency: CryptoCurrency = assetType == .bitcoin ? .bitcoin : .bitcoin
        bitpayService
            .verifySignedTransaction(
                invoiceID: invoiceID,
                currency: currency,
                transactionHex: transactionHex,
                transactionSize: size
            )
            .flatMap(weak: self) { (self, memo) -> Single<BitPayMemo> in
                self.bitpayService.postPayment(
                    invoiceID: invoiceID,
                    currency: currency,
                    transactionHex: transactionHex,
                    transactionSize: size
                )
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { memo in
                    completion(memo.memo, nil)
                },
                onError: { error in
                    completion(nil, error)
                }
            )
            .disposed(by: disposeBag)
    }
}
