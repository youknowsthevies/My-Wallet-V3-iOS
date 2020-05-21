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
    case trading(CryptoCurrency)
    case savings(CryptoCurrency)
    case nonCustodial(CryptoCurrency)
}

final class DashboardDetailsScreenPresenter {
        
    private typealias LocalizedString = LocalizationConstants.DashboardDetails.BalanceCell
    
    enum BalancePresentationState {
        case visible(CurrentBalanceCellPresenter)
        
        // TODO: Currently not handled
        case hidden
                
        var presenter: CurrentBalanceCellPresenter? {
            switch self {
            case .visible(let presenter):
                return presenter
            case .hidden:
                return nil
            }
        }
        
        var isVisible: Bool {
            switch self {
            case .visible:
                return true
            case .hidden:
                return false
            }
        }
    }
    
    enum PresentationAction {
        case show(BalanceType)
    }

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
    
    var presentationAction: Signal<PresentationAction> {
        presentationActionRelay.asSignal()
    }
        
    // MARK: - Exposed Properties
    
    var walletBalancePresenter: CurrentBalanceCellPresenter? {
        walletBalanceStateRelay.value.presenter
    }
    
    var tradingBalancePresenter: CurrentBalanceCellPresenter? {
        tradingBalanceStateRelay.value.presenter
    }
    
    var savingsBalancePresenter: CurrentBalanceCellPresenter? {
        savingsBalanceStateRelay.value.presenter
    }
    
    var shouldShowNonCustodialBalance: Bool {
        walletBalancePresenter != nil
    }
    
    var shouldShowTradingBalance: Bool {
        tradingBalancePresenter != nil
    }
    
    var shouldShowSavingsBalance: Bool {
        savingsBalancePresenter != nil
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
        var cellTypes: [CellType] = .default
        if shouldShowNonCustodialBalance {
            cellTypes.append(.balance(.nonCustodial))
        }
        if shouldShowTradingBalance {
            cellTypes.append(.balance(.custodial(.trading)))
        }
        if shouldShowSavingsBalance {
            cellTypes.append(.balance(.custodial(.savings)))
        }
        return cellTypes
    }
    
    var indexByCellType: [CellType: Int] {
        var indexByCellType: [CellType: Int] = [:]
        for (index, cellType) in cellArrangement.enumerated() {
            indexByCellType[cellType] = index
        }
        return indexByCellType
    }
    
    // MARK: - Public Properties (Presenters)
    
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
    
    private let presentationActionRelay = PublishRelay<PresentationAction>()
    private let walletBalanceStateRelay = BehaviorRelay<BalancePresentationState>(value: .hidden)
    private let tradingBalanceStateRelay = BehaviorRelay<BalancePresentationState>(value: .hidden)
    private let savingsBalanceStateRelay = BehaviorRelay<BalancePresentationState>(value: .hidden)
    
    private unowned let router: DashboardRouter
    private let interactor: DashboardDetailsScreenInteractor
    private let actionRelay = PublishRelay<DashboadDetailsAction>()
    private let scrollingEnabledRelay = BehaviorRelay(value: false)
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(using interactor: DashboardDetailsScreenInteractor,
         with currency: CryptoCurrency,
         fiatCurrency: FiatCurrency,
         router: DashboardRouter) {
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
        
        presenterSelectionRelay
            .compactMap { cellType -> BalanceType? in
                guard case let .balance(balanceType) = cellType else { return nil }
                return balanceType
            }
            .map { balanceType in
                switch balanceType {
                case .nonCustodial:
                    return .nonCustodial(currency)
                case .custodial(.trading):
                    return .trading(currency)
                case .custodial(.savings):
                    return .savings(currency)
                }
            }
            .bind(to: actionRelay)
            .disposed(by: disposeBag)
    }
    
    /// Should be called on `viewDidLoad`
    func setup() {
        setupWalletBalancePresenter()
        setupTradingBalancePresenter()
        setupSavingsBalancePresenter()
        
        interactor.refresh()
    }
    
    private func setupWalletBalancePresenter() {
        let walletBalancePresenter = balanceCellPresenter(for: .nonCustodial)
        walletBalanceStateRelay.accept(.visible(walletBalancePresenter))
        presentationActionRelay.accept(.show(.nonCustodial))
    }
        
    private func setupSavingsBalancePresenter() {
        interactor.savingsBalanceInteractor.exists
            .filter { $0 }
            .take(1) // This to ensure the cell shows only once
            .map(weak: self) { (self, exists) in
                guard exists else { return .hidden }
                return .visible(
                    self.balanceCellPresenter(for: .custodial(.savings))
                )
            }
            .bind(to: savingsBalanceStateRelay)
            .disposed(by: disposeBag)
        
        savingsBalanceStateRelay
            .filter { $0.isVisible }
            .mapToVoid()
            .map { .show(.custodial(.savings)) }
            .bind(to: presentationActionRelay)
            .disposed(by: disposeBag)
    }
    
    private func setupTradingBalancePresenter() {
        interactor.tradingBalanceInteractor.exists
            .filter { $0 }
            .take(1) // This to ensure the cell shows only once
            .map(weak: self) { (self, exists) in
                guard exists else { return .hidden }
                return .visible(
                    self.balanceCellPresenter(for: .custodial(.trading))
                )
            }
            .bind(to: tradingBalanceStateRelay)
            .disposed(by: disposeBag)
        
        tradingBalanceStateRelay
            .filter { $0.isVisible }
            .mapToVoid()
            .map { .show(.custodial(.trading)) }
            .bind(to: presentationActionRelay)
            .disposed(by: disposeBag)
    }
    
    private func balanceCellPresenter(for balanceType: BalanceType) -> CurrentBalanceCellPresenter {
        
        let descriptionValue: () -> Observable<String> = { [weak self] in
            guard let self = self else { return .empty() }
            switch balanceType {
            case .nonCustodial:
                return .just(LocalizedString.Description.nonCustodial)
            case .custodial(.savings):
                return self.interactor.savingsAccountService
                    .rate(for: self.currency)
                    .asObservable()
                    .compactMap { $0 }
                    .map { "\(LocalizedString.Description.savingsPrefix) \($0)\(LocalizedString.Description.savingsSuffix)" }
            case .custodial(.trading):
                return .just(LocalizedString.Description.trading)
            }
        }
    
        return CurrentBalanceCellPresenter(
            balanceFetcher: interactor.balanceFetcher,
            descriptionValue: descriptionValue,
            currency: currency,
            balanceType: balanceType,
            alignment: .trailing
        )
    }
    
    private lazy var sendRequestItems: [SegmentedViewModel.Item] = {
        typealias LocalizedString = LocalizationConstants.Dashboard
        let currency = self.currency
        let actionRelay = self.actionRelay
        
        return [
            .text(
                LocalizedString.send,
                action: {
                    actionRelay.accept(.send(currency))
                }
            ),
            .text(
                LocalizedString.request,
                action: {
                    actionRelay.accept(.request(currency))
                }
            )
        ]
    }()
}

extension Array where Element == DashboardDetailsScreenPresenter.CellType {
    static var `default`: [Element] {
        [
            .sendRequest,
            .priceAlert,
            .chart
        ]
    }
}
