//
//  WalletPickerInteractor.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

public final class WalletPickerInteractor {

    public var interactors: Observable<[WalletPickerCellInteractor]> {
        Observable.combineLatest(
                totalWalletBalanceInteractor,
                balanceCellInteractors
            )
            .map { $0.0 + $0.1 }
    }

    public var balanceCellInteractors: Observable<[WalletPickerCellInteractor]> {
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
        .just(
            [.total(WalletBalanceCellInteractor(balanceViewInteractor: WalletBalanceViewInteractor(balanceProviding: balanceProviding)))]
        )
    }

    private let balanceProviding: BalanceProviding
    private var providers: [CryptoCurrency: WalletPickerCellInteractorProviding] = [:]
    private let selectionService: WalletPickerSelectionServiceAPI
    private let disposeBag = DisposeBag()

    public init(balanceProviding: BalanceProviding,
                tether: WalletPickerCellInteractorProviding,
                algorand: WalletPickerCellInteractorProviding,
                ethereum: WalletPickerCellInteractorProviding,
                pax: WalletPickerCellInteractorProviding,
                stellar: WalletPickerCellInteractorProviding,
                bitcoin: WalletPickerCellInteractorProviding,
                bitcoinCash: WalletPickerCellInteractorProviding,
                selectionService: WalletPickerSelectionServiceAPI) {
        self.balanceProviding = balanceProviding
        self.selectionService = selectionService
        providers[.tether] = tether
        providers[.algorand] = algorand
        providers[.ethereum] = ethereum
        providers[.pax] = pax
        providers[.stellar] = stellar
        providers[.bitcoin] = bitcoin
        providers[.bitcoinCash] = bitcoinCash
    }

    public func record(selection: WalletPickerSelection) {
        selectionService.record(selection: selection)
    }
}
