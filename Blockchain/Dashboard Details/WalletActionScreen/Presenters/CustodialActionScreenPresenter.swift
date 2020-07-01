//
//  CustodialActionScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

final class CustodialActionScreenPresenter: WalletActionScreenPresenting {
    
    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.DashboardDetails
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
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
    private let analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording
    private let interactor: WalletActionScreenInteracting
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(using interactor: WalletActionScreenInteracting,
         stateService: CustodyActionStateServiceAPI,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared) {
        self.analyticsRecorder = analyticsRecorder
        self.interactor = interactor
        
        if interactor.balanceType == .custodial(.trading) {
            analyticsRecorder.record(
                event: AnalyticsEvent.sbTradingWalletClicked(asset: interactor.currency)
            )
        }
        
        let descriptionValue: () -> Observable<String> = {
            .just(LocalizationConstants.DashboardDetails.BalanceCell.Description.trading)
        }
        
        assetBalanceViewPresenter = CurrentBalanceCellPresenter(
            interactor: interactor.balanceCellInteractor,
            descriptionValue: descriptionValue,
            currency: interactor.currency,
            alignment: .trailing,
            titleAccessibilitySuffix: "\(AccessibilityId.CurrentBalanceCell.titleValue)",
            descriptionAccessibilitySuffix: "\(AccessibilityId.CurrentBalanceCell.descriptionValue)",
            descriptors: .default(
                cryptoAccessiblitySuffix: "\(AccessibilityId.WalletActionSheet.CustodialAction.cryptoValue)",
                fiatAccessiblitySuffix: "\(AccessibilityId.WalletActionSheet.CustodialAction.fiatValue)"
            )
        )
        
        swapButtonViewModel = .primary(with: "")
        activityButtonViewModel = .secondary(with: LocalizationConstants.DashboardDetails.viewActivity)
        sendToWalletViewModel = .primary(with: LocalizationConstants.DashboardDetails.sendToWallet)

        sendToWalletViewModel.tapRelay
            .bindAndCatch(to: stateService.nextRelay)
            .disposed(by: disposeBag)
        sendToWalletViewModel.tapRelay
            .map { _ in AnalyticsEvent.sbTradingWalletClicked(asset: interactor.currency) }
            .bindAndCatch(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)

        activityButtonViewModel.tapRelay
            .bindAndCatch(to: stateService.activityRelay)
            .disposed(by: disposeBag)

        let isCustodial = interactor.balanceType.isCustodial
        let isTrading = interactor.balanceType.isTrading
        let isSavings = interactor.balanceType.isSavings
        activityButtonVisibilityRelay.accept(!isSavings ? .visible : .hidden)
        swapButtonVisibilityRelay.accept(!isCustodial ? .visible : .hidden)
        sendToWalletVisibilityRelay.accept(isTrading && currency.hasNonCustodialSupport ? .visible : .hidden)
    }
}

