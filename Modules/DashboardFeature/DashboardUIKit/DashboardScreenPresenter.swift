//
//  DashboardScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 22/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

public protocol AnnouncementPresenting {
    
    var announcement: Driver<AnnouncementDisplayAction> { get }
    
    func refresh()
}

/// This enum aggregates possible action types that can be done in the dashboard
enum DashboardCollectionAction {
    
    /// Any action related to announcement
    case announcement(AnnouncementDisplayAction)
    
    /// Any action related to notice about the wallet state
    case notice(DashboardItemDisplayAction<NoticeViewModel>)
    
    /// Any action related to the custodial fiat balances
    case fiatBalance(DashboardItemDisplayAction<ViewPresenter>)
    
    case actionScreen(DashboardItemDisplayAction<CurrencyType>)
}

enum DashboardItemState {
    case hidden
    case visible(index: Int)
    
    var isVisible: Bool {
        switch self {
        case .visible:
            return true
        case .hidden:
            return false
        }
    }
}

final class DashboardScreenPresenter {
    
    // MARK: - Types
    
    enum AnnouncementArrangement {
        
        /// Announcement card should show at the top of the dashboard
        case top
        
        /// Announcement card should show at the bottom of the dashboard
        case bottom
        
        /// Announcement card should not show at all
        case none
    }
    
    enum CellType: Hashable {
        case announcement
        case fiatCustodialBalances
        case totalBalance
        case notice
        case crypto(CryptoCurrency)
    }
    
    // MARK: - Exposed Properties
    
    /// The dashboard action
    var action: Signal<DashboardCollectionAction> {
        actionRelay.asSignal()
    }
    
    /// Returns the total count of cells
    var cellCount: Int {
        cellArrangement.count
    }
    
    /// Returns the ordered cell types
    var cellArrangement: [CellType] {
        var cellTypes: [CellType] = []
        cellTypes += [.totalBalance]
        
        if shouldShowNotice {
            cellTypes.append(.notice)
        }
        
        if shouldShowBalanceCollectionView {
            cellTypes.append(.fiatCustodialBalances)
        }
                
        let assetCells: [CellType] = interactor.enabledCryptoCurrencies.map { .crypto($0) }
        assetCells.forEach { cellTypes.append($0) }
        
        switch announcementCardArrangement {
        case .top: // Prepend
            cellTypes = [.announcement] + cellTypes
        case .bottom: // Append
            cellTypes += [.announcement]
        case .none:
            break
        }
        
        return cellTypes
    }
    
    private var firstAssetCellIndex: Int {
        let firstCrypto = historicalBalanceCellPresenters[0].cryptoCurrency
        let firstCryptoCellType = CellType.crypto(firstCrypto)
        return indexByCellType[firstCryptoCellType]!
    }
    
    var announcementCellIndex: Int? {
        indexByCellType[.announcement]
    }
        
    var indexByCellType: [CellType: Int] {
        var indexByCellType: [CellType: Int] = [:]
        for (index, cellType) in cellArrangement.enumerated() {
            indexByCellType[cellType] = index
        }
        return indexByCellType
    }

    // MARK: - Announcement
    
    /// `true` in case a card announcement should show
    var announcementCardArrangement: AnnouncementArrangement {
        guard let announcementCardViewModel = announcementCardViewModel else {
            return .none
        }
        switch announcementCardViewModel.priority {
        case .high:
            return .top
        case .low:
            return .bottom
        }
    }
        
    var cardState = DashboardItemState.hidden
    private(set) var announcementCardViewModel: AnnouncementCardViewModel!
    private let announcmentPresenter: AnnouncementPresenting
    
    // MARK: - Balances
    
    let totalBalancePresenter: TotalBalanceViewPresenter
    
    private var shouldShowBalanceCollectionView: Bool {
        fiatBalanceCollectionViewPresenter != nil
    }
    
    var fiatBalanceState = DashboardItemState.hidden
    private(set) var fiatBalanceCollectionViewPresenter: ViewPresenter!
    let fiatBalancePresenter: DashboardFiatBalancesPresenter
    
    // MARK: - Notice
    
    /// Returns `true` if the notice cell should be visible
    private var shouldShowNotice: Bool {
        noticeViewModel != nil
    }
    
    /// Presenter for wallet notice
    var noticeState = DashboardItemState.hidden
    private(set) var noticeViewModel: NoticeViewModel!
    private let noticePresenter: DashboardNoticePresenter
    
    // MARK: - Historical Balances
    
    private let historicalBalanceCellPresenters: [HistoricalBalanceCellPresenter]
    
    // MARK: - Interactor

    private let drawerRouter: DrawerRouting
    private let interactor: DashboardScreenInteractor
    
    // MARK: - Accessors
    
    private let actionRelay = PublishRelay<DashboardCollectionAction>()
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(interactor: DashboardScreenInteractor = DashboardScreenInteractor(),
         drawerRouter: DrawerRouting = resolve(),
         announcmentPresenter: AnnouncementPresenting = resolve()) {
        self.interactor = interactor
        self.drawerRouter = drawerRouter
        self.announcmentPresenter = announcmentPresenter
        totalBalancePresenter = TotalBalanceViewPresenter(
            balanceProvider: interactor.balanceProvider,
            balanceChangeProvider: interactor.balanceChangeProvider,
            enabledCurrenciesService: interactor.enabledCurrenciesService
        )
        noticePresenter = DashboardNoticePresenter()
        historicalBalanceCellPresenters = interactor
            .historicalBalanceInteractors
            .map { .init(interactor: $0) }
        fiatBalancePresenter = DashboardFiatBalancesPresenter(
            interactor: interactor.fiatBalancesInteractor
        )
    }
    
    /// Should be called once the view is loaded
    func setup() {
        // Bind announcements
        announcmentPresenter.announcement
            .do(onNext: { action in
                switch action {
                case .hide:
                    self.announcementCardViewModel = nil
                case .show(let viewModel):
                    self.announcementCardViewModel = viewModel
                case .none:
                    break
                }
            })
            .map { .announcement($0) }
            .asObservable()
            .bindAndCatch(to: actionRelay)
            .disposed(by: disposeBag)
        
        // Bind notices
        noticePresenter.action
            .do(onNext: { action in
                switch action {
                case .hide:
                    self.noticeViewModel = nil
                case .show(let viewModel):
                    self.noticeViewModel = viewModel
                }
            })
            .map { .notice($0) }
            .asObservable()
            .bindAndCatch(to: actionRelay)
            .disposed(by: disposeBag)
        
        fiatBalancePresenter.action
            .do(onNext: { action in
                switch action {
                case .hide:
                    self.fiatBalanceCollectionViewPresenter = nil
                case .show(let presenter):
                    self.fiatBalanceCollectionViewPresenter = presenter
                }
            })
            .map { .fiatBalance($0) }
            .asObservable()
            .bindAndCatch(to: actionRelay)
            .disposed(by: disposeBag)
        
        fiatBalancePresenter
            .tap
            .map { .actionScreen($0) }
            .asObservable()
            .bindAndCatch(to: actionRelay)
            .disposed(by: disposeBag)
    }
    
    /// Should be called each time the dashboard view shows
    /// to trigger dashboard re-render
    func refresh() {
        interactor.refresh()
        announcmentPresenter.refresh()
        noticePresenter.refresh()
        fiatBalancePresenter.refresh()
    }
    
    /// Given the cell index, returns the historical balance presenter
    func historicalBalancePresenter(by cellIndex: Int) -> HistoricalBalanceCellPresenter {
        historicalBalanceCellPresenters[cellIndex - firstAssetCellIndex]
    }
    
    // MARK: - Navigation
    
    /// Should be invoked upon tapping navigation bar leading button
    func navigationBarLeadingButtonPressed() {
        drawerRouter.toggleSideMenu()
    }
}
