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
        interactorsRelay.asObservable()
    }
    
    private let interactorsRelay = BehaviorRelay<[WalletPickerCellInteractor]>(value: [])
    private let disposeBag = DisposeBag()
    
    init(balanceFetcher: AssetBalanceFetching, currency: CryptoCurrency) {
        interactors(for: currency, balanceFetching: balanceFetcher)
            .bind(to: interactorsRelay)
            .disposed(by: disposeBag)
    }
    
    private func interactors(for currency: CryptoCurrency,
                             balanceFetching: AssetBalanceFetching) -> Observable<[WalletPickerCellInteractor]> {
        balanceFetching
            .trading
            .isFunded
            .map { isFunded -> [CurrentBalanceCellInteractor] in
                var result: [CurrentBalanceCellInteractor] = []
                if currency.hasNonCustodialSupport {
                    result.append(
                        CurrentBalanceCellInteractor(
                            balanceFetching: balanceFetching,
                            balanceType: .nonCustodial
                        )
                    )
                }
                if isFunded {
                    result.append(
                        CurrentBalanceCellInteractor(
                            balanceFetching: balanceFetching,
                            balanceType: .custodial(.trading)
                        )
                    )
                }
                return result
            }
            .map { interactors in
                interactors.map { .balance($0, currency) }
            }
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
                providers[.ethereum]!.interactors,
                providers[.bitcoin]!.interactors,
                providers[.bitcoinCash]!.interactors,
                providers[.pax]!.interactors,
                providers[.stellar]!.interactors,
                providers[.algorand]!.interactors
            )
            .map { arg in
                let (ethereum, bitcoin, bitcoinCash, pax, stellar, algorand) = arg
                return ethereum + bitcoin + bitcoinCash + pax + stellar + algorand
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
    private let interactorsRelay = BehaviorRelay<[WalletPickerCellInteractor]>(value: [])
    private let selectionService: WalletPickerSelectionServiceAPI
    private let disposeBag = DisposeBag()
    
    init(balanceProviding: BalanceProviding,
         algorand: WalletPickerCellInteractorProvider,
         ether: WalletPickerCellInteractorProvider,
         pax: WalletPickerCellInteractorProvider,
         stellar: WalletPickerCellInteractorProvider,
         bitcoin: WalletPickerCellInteractorProvider,
         bitcoinCash: WalletPickerCellInteractorProvider,
         selectionService: WalletPickerSelectionServiceAPI) {
        self.balanceProviding = balanceProviding
        self.selectionService = selectionService
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
