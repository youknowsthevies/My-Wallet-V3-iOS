//
//  WalletPickerCellInteractorProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

public protocol WalletPickerCellInteractorProviding {
    var interactors: Observable<[WalletPickerCellInteractor]> { get }
}

public final class WalletPickerCellInteractorProvider: WalletPickerCellInteractorProviding {
    
    public var interactors: Observable<[WalletPickerCellInteractor]> {
        _ = setup
        return interactorsRelay.asObservable()
    }

    private let interactorsRelay = BehaviorRelay<[WalletPickerCellInteractor]>(value: [])
    private let balanceFetcher: AssetBalanceFetching
    private let currency: CryptoCurrency
    private let balanceTypes: [BalanceType]
    private let isEnabled: Bool
    private let disposeBag = DisposeBag()

    private lazy var setup: Void = {
        guard isEnabled else {
            return
        }
        return balanceFetcher
            .trading
            .isFunded
            .map(weak: self) { (self, isFunded) -> [CurrentBalanceCellInteracting] in
                var result: [CurrentBalanceCellInteracting] = []
                if self.currency.hasNonCustodialActivitySupport, self.balanceTypes.contains(.nonCustodial) {
                    result.append(
                        CurrentBalanceCellInteractor(
                            balanceFetching: self.balanceFetcher,
                            balanceType: .nonCustodial
                        )
                    )
                }
                if isFunded, self.balanceTypes.contains(.custodial(.trading)) {
                    result.append(
                        CurrentBalanceCellInteractor(
                            balanceFetching: self.balanceFetcher,
                            balanceType: .custodial(.trading)
                        )
                    )
                }
                return result
            }
            .map(weak: self) { (self, interactors) in
                interactors.map { .balance($0, self.currency) }
            }
            .bindAndCatch(to: interactorsRelay)
            .disposed(by: disposeBag)
    }()
    
    public init(balanceFetcher: AssetBalanceFetching,
                currency: CryptoCurrency,
                isEnabled: Bool,
                balanceTypes: [BalanceType] = BalanceType.allCases) {
        self.balanceFetcher = balanceFetcher
        self.currency = currency
        self.isEnabled = isEnabled
        self.balanceTypes = balanceTypes
    }
}
