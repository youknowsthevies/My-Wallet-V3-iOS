//
//  WalletPickerScreenInteractor.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

enum WalletPickerCellInteractor {
    case total(WalletBalanceCellInteractor)
    case balance(CurrentBalanceCellInteractor, CryptoCurrency)
}

final class WalletPickerCellInteractorProvider {
    
    var interactors: Observable<[WalletPickerCellInteractor]> {
        _ = setup
        return interactorsRelay.asObservable()
    }

    private let interactorsRelay = BehaviorRelay<[WalletPickerCellInteractor]>(value: [])
    private let balanceFetcher: AssetBalanceFetching
    private let currency: CryptoCurrency
    private let disposeBag = DisposeBag()

    private lazy var setup: Void = {
        guard CryptoCurrency.allEnabled.contains(currency) else {
            return
        }
        return balanceFetcher
            .trading
            .isFunded
            .map(weak: self) { (self, isFunded) -> [CurrentBalanceCellInteractor] in
                var result: [CurrentBalanceCellInteractor] = []
                if self.currency.hasNonCustodialActivitySupport {
                    result.append(
                        CurrentBalanceCellInteractor(
                            balanceFetching: self.balanceFetcher,
                            balanceType: .nonCustodial
                        )
                    )
                }
                if isFunded {
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
    
    init(balanceFetcher: AssetBalanceFetching, currency: CryptoCurrency) {
        self.balanceFetcher = balanceFetcher
        self.currency = currency
    }
}

final class WalletPickerScreenInteractor {
    
    var interactors: Observable<[WalletPickerCellInteractor]> {
        Observable.combineLatest(
                totalWalletBalanceInteractor,
                balanceCellInteractors
            )
            .map { $0.0 + $0.1 }
    }
    
    private var balanceCellInteractors: Observable<[WalletPickerCellInteractor]> {
        Observable
            .combineLatest(
                providers[.bitcoin]!.interactors,
                providers[.ethereum]!.interactors,
                providers[.bitcoinCash]!.interactors,
                providers[.stellar]!.interactors,
                providers[.algorand]!.interactors,
                providers[.tether]!.interactors,
                providers[.pax]!.interactors
            )
            .map { interactors in
                let (bitcoin, ethereum, bitcoinCash, stellar, algorand, tether, pax) = interactors
                return bitcoin + ethereum + bitcoinCash + stellar + algorand + pax + tether
            }
    }
    
    private var totalWalletBalanceInteractor: Observable<[WalletPickerCellInteractor]> {
        Observable.just(
            .init(balanceViewInteractor: .init(balanceProviding: balanceProviding))
            )
            .map { [.total($0)] }
    }
    
    let balanceProviding: BalanceProviding
    
    private var providers: [CryptoCurrency: WalletPickerCellInteractorProvider] = [:]
    private let selectionService: WalletPickerSelectionServiceAPI
    private let disposeBag = DisposeBag()
    
    init(balanceProviding: BalanceProviding,
         tether: WalletPickerCellInteractorProvider,
         algorand: WalletPickerCellInteractorProvider,
         ether: WalletPickerCellInteractorProvider,
         pax: WalletPickerCellInteractorProvider,
         stellar: WalletPickerCellInteractorProvider,
         bitcoin: WalletPickerCellInteractorProvider,
         bitcoinCash: WalletPickerCellInteractorProvider,
         selectionService: WalletPickerSelectionServiceAPI) {
        self.balanceProviding = balanceProviding
        self.selectionService = selectionService
        providers[.tether] = tether
        providers[.algorand] = algorand
        providers[.ethereum] = ether
        providers[.pax] = pax
        providers[.stellar] = stellar
        providers[.bitcoin] = bitcoin
        providers[.bitcoinCash] = bitcoinCash
    }
    
    func record(selection: WalletPickerSelection) {
        selectionService.selectedDataRelay.accept(selection)
    }
}
