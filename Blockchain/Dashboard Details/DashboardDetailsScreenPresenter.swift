//
//  DashboardDetailsScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformKit
import PlatformUIKit

/// This enum aggregates possible action types that can be done in the dashboard
enum DashboadDetailsAction {
    case send(CryptoCurrency)
    case request(CryptoCurrency)
    case buy(CryptoCurrency)
    case custody(CryptoCurrency)
    case nonCustodial(CryptoCurrency)
}

/// Handles updating the collection displayed
enum DashboardDetailsCollectionAction {
    case custodial(CustodialCellTypeAction)
}

final class DashboardDetailsScreenPresenter {
    
    // MARK: - Navigation Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        .none
    }
    
    var leadingButton: Screen.Style.LeadingButton {
        .close
    }
    
    var titleView: Screen.Style.TitleView {
        .text(value: currency.name)
    }
    
    var barStyle: Screen.Style.Bar {
        .lightContent(ignoresStatusBar: false, background: .navigationBarBackground)
    }
    
    // MARK: - Types
    
    enum CellType: Hashable {
        case balance(BalanceType)
        case sendRequest
        case priceAlert
        case chart
    }
    
    // MARK: - Rx
    
    var isScrollEnabled: Driver<Bool> {
        scrollingEnabledRelay.asDriver()
    }
    
    private let scrollingEnabledRelay = BehaviorRelay(value: false)
    
    // MARK: - Exposed Properties
    
    var shouldShowCustodialBalance: Bool {
        custodyAssetBalanceViewPresenter != nil
    }
    
    var collectionAction: Signal<DashboardDetailsCollectionAction> {
        collectionActionRelay.asSignal()
    }
    
    /// The dashboard action
    var action: Signal<DashboadDetailsAction> {
        actionRelay.asSignal()
    }
    
    /// Returns the total count of cells
    var cellCount: Int {
        cellArrangement.count
    }
    
    /// Returns the ordered cell types
    var cellArrangement: [CellType] {
        shouldShowCustodialBalance ? .default + [.balance(.custodial)] : .default
    }
    
    var indexByCellType: [CellType: Int] {
        var indexByCellType: [CellType: Int] = [:]
        for (index, cellType) in cellArrangement.enumerated() {
            indexByCellType[cellType] = index
        }
        return indexByCellType
    }
    
    // MARK: - Public Properties (Presenters)
    
    var balanceCellPresenter: CurrentBalanceCellPresenter {
        CurrentBalanceCellPresenter(
            balanceFetching: interactor.balanceFetching,
            currency: currency,
            balanceType: .nonCustodial,
            alignment: .trailing
        )
    }
    
    private(set) var custodyAssetBalanceViewPresenter: CurrentBalanceCellPresenter!
    
    var sendRequestPresenter: MultiActionViewPresenting {
        PlainActionViewPresenter(
            using: sendRequestItems
        )
    }
    
    let lineChartCellPresenter: AssetLineChartTableViewCellPresenter
    
    let currency: CryptoCurrency
    
    /// Selection relay for a single presenter
    let presenterSelectionRelay = PublishRelay<CellType>()
    
    // MARK: - Private Properties
    
    private unowned let router: DashboardRouter
    private let interactor: DashboardDetailsScreenInteracting
    private let collectionActionRelay = PublishRelay<DashboardDetailsCollectionAction>()
    private let actionRelay = PublishRelay<DashboadDetailsAction>()
    private let custodialPresenter: DashboardDetailsCustodialTypePresenter
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(using interactor: DashboardDetailsScreenInteracting,
         with currency: CryptoCurrency,
         fiatCurrency: FiatCurrency,
         router: DashboardRouter) {
        let custodialBalanceFetching = interactor.balanceFetching.custodialBalance
        self.custodialPresenter = DashboardDetailsCustodialTypePresenter(balanceFetching: custodialBalanceFetching)
        self.router = router
        self.currency = currency
        self.interactor = interactor
        
        lineChartCellPresenter = AssetLineChartTableViewCellPresenter(
            cryptoCurrency: currency,
            fiatCurrency: fiatCurrency,
            historicalFiatPriceService: interactor.priceServiceAPI
        )
        
        lineChartCellPresenter.isScrollEnabled
            .drive(scrollingEnabledRelay)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(presenterSelectionRelay,
                                 interactor.recoveryPhraseStatus.isRecoveryPhraseVerified)
            .bind { [weak self] (cellType, verified) in
                guard let self = self else { return }
                guard case let .balance(balanceType) = cellType else { return }
                switch balanceType {
                case .custodial:
                    self.actionRelay.accept(.custody(currency))
                case .nonCustodial:
                    self.actionRelay.accept(.nonCustodial(currency))
            }
        }
        .disposed(by: disposeBag)
    }
    
    /// Should be called on `viewDidLoad`
    func setup() {
        custodialPresenter.action
            .do(onNext: { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .show:
                    self.custodyAssetBalanceViewPresenter = CurrentBalanceCellPresenter(
                        balanceFetching: self.interactor.balanceFetching,
                        currency: self.currency,
                        balanceType: .custodial,
                        alignment: .trailing
                    )
                case .none:
                    self.custodyAssetBalanceViewPresenter = nil
                }
            })
            .asObservable()
            .map { .custodial($0) }
            .bind(to: collectionActionRelay)
            .disposed(by: disposeBag)
    }
    
    /// Should be called each time the dashboard view shows
    /// to trigger dashboard re-render
    func refresh() {
        interactor.refresh()
    }
    
    private lazy var sendRequestItems: [SegmentedViewModel.Item] = {
        return [.text("Send", action: { [weak self] in
                    guard let self = self else { return }
                    self.actionRelay.accept(.send(self.currency))
                    }
                ),
                .text("Request", action: { [weak self] in
                    guard let self = self else { return }
                    self.actionRelay.accept(.request(self.currency))
                })]
    }()
}

extension Array where Element == DashboardDetailsScreenPresenter.CellType {
    static var `default`: [Element] {
        [.sendRequest,
        .priceAlert,
        .chart,
        .balance(.nonCustodial)]
    }
}
