//
//  CustodialActionScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import PlatformKit
import PlatformUIKit

final class CustodialActionScreenPresenter: WalletActionScreenPresenting {
    
    // MARK: - Types
    
    typealias CellType = WalletActionCellType
    
    // MARK: - Public Properties
    
    /// Returns the total count of cells
    var cellCount: Int {
        cellArrangement.count
    }
    
    /// Returns the ordered cell types
    var cellArrangement: [CellType] {
        [.balance]
    }
    
    var swapButtonVisibility: Driver<Visibility> {
        swapButtonVisibilityRelay.asDriver()
    }
    
    var activityButtonVisibility: Driver<Visibility> {
        activityButtonVisibilityRelay.asDriver()
    }
    
    var sendToWalletVisibility: Driver<Visibility> {
        sendToWalletVisibilityRelay.asDriver()
    }
    
    let assetBalanceViewPresenter: CurrentBalanceCellPresenter
    let sendToWalletViewModel: ButtonViewModel
    let activityButtonViewModel: ButtonViewModel
    let swapButtonViewModel: ButtonViewModel
    
    var currency: CryptoCurrency {
        interactor.currency
    }
    
    // MARK: - Private Properties
    
    private let swapButtonVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let activityButtonVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let sendToWalletVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let interactor: WalletActionScreenInteracting
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(using interactor: WalletActionScreenInteracting,
         stateService: RoutingNextStateEmitterAPI) {
        self.interactor = interactor
        
        assetBalanceViewPresenter = CurrentBalanceCellPresenter(
            balanceFetching: interactor.balanceFetching,
            currency: interactor.currency,
            balanceType: interactor.balanceType,
            alignment: .trailing
        )
        
        activityButtonVisibilityRelay.accept(interactor.balanceType == .nonCustodial ? .visible : .hidden)
        swapButtonVisibilityRelay.accept(interactor.balanceType == .nonCustodial ? .visible : .hidden)
        sendToWalletVisibilityRelay.accept(interactor.balanceType == .custodial ? .visible : .hidden)
        
        swapButtonViewModel = .primary(with: "")
        activityButtonViewModel = .secondary(with: "")
        
        sendToWalletViewModel = .primary(with: LocalizationConstants.DashboardDetails.sendToWallet)
        sendToWalletViewModel.tapRelay
            .bind(to: stateService.nextRelay)
            .disposed(by: disposeBag)
    }
    
}

