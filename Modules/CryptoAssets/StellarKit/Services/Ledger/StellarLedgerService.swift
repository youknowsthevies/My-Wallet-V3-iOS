// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift
import stellarsdk

final class StellarLedgerService: StellarLedgerServiceAPI {

    // MARK: - StellarLedgerServiceAPI
    
    let fallbackBaseReserve: Decimal = 0.5
    let fallbackBaseFee: Decimal = CryptoValue.stellar(minor: StellarTransactionFee.defaultLimits.min).displayMajorValue
    
    var current: Observable<StellarLedger> {
        guard let cachedValue = privateLedger.value else {
            return fetchLedger.asObservable()
        }
        return fetchLedger.asObservable().startWith(cachedValue)
    }
    
    var currentLedger: StellarLedger? {
        privateLedger.value
    }
    
    private let privateLedger = BehaviorRelay<StellarLedger?>(value: nil)
    
    private var fetchLedger: Single<StellarLedger> {
        Single.zip(getLedgers, feeService.fees)
            .flatMap { (ledger, fees) -> Single<StellarLedger> in
                // Convert from Lumens to stroops
                guard let baseFeeInStroops: Int = Int(fees.regular.minorString) else {
                    return Single.just(ledger.apply(baseFeeInStroops: StellarTransactionFee.defaultLimits.min))
                }
                return Single.just(ledger.apply(baseFeeInStroops: baseFeeInStroops))
            }
            .do(onSuccess: { [weak self] ledger in
                self?.privateLedger.accept(ledger)
            })
    }
    
    private var getLedgers: Single<StellarLedger> {
        ledgersServiceProvider.ledgersService
            .flatMap(weak: self) { (self, ledgersService) -> Single<StellarLedger> in
                ledgersService.ledgers(cursor: nil, order: .descending, limit: 1)
            }
    }

    private let ledgersServiceProvider: LedgersServiceProviderAPI
    private let feeService: AnyCryptoFeeService<StellarTransactionFee>
    
    init(ledgersServiceProvider: LedgersServiceProviderAPI = resolve(),
         feeService: AnyCryptoFeeService<StellarTransactionFee> = resolve()) {
        self.ledgersServiceProvider = ledgersServiceProvider
        self.feeService = feeService
    }
}
