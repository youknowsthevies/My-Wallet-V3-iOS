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

final class WalletPickerScreenInteractor {
    
    enum CellInteractor {
        case total(WalletBalanceCellInteractor)
        case balance(CurrentBalanceCellInteractor, CryptoCurrency)
    }
    
    var interactors: Observable<[CellInteractor]> {
        interactorsRelay
            .asObservable()
    }
    
    let balanceProviding: BalanceProviding
    
    private let interactorsRelay = BehaviorRelay<[CellInteractor]>(value: [])
    private let selectionService: WalletPickerSelectionServiceAPI
    private let currencies = Observable.just(CryptoCurrency.all)
    private let disposeBag = DisposeBag()
    
    init(balanceProviding: BalanceProviding,
         selectionService: WalletPickerSelectionServiceAPI) {
        self.balanceProviding = balanceProviding
        self.selectionService = selectionService
        
        let wallet = WalletBalanceCellInteractor.init(
            balanceViewInteractor: .init(
                balanceProviding: balanceProviding
            )
        )
        
        let noncustodial: [CellInteractor] = CryptoCurrency.all
            .map { (balanceProviding[$0], $0) }
            .map {
                (CurrentBalanceCellInteractor(balanceFetching: $0.0, balanceType: .nonCustodial), $0.1)
            }
            .map { .balance($0.0, $0.1) }
        
        let presenters = [.total(wallet)] + noncustodial
        
        interactorsRelay.accept(presenters)
    }
    
    func record(selection: WalletPickerSelection) {
        selectionService.selectedDataRelay.accept(selection)
    }
}
