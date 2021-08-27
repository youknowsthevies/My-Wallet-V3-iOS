// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class DashboardScreenPresenter {

    // MARK: - Internal Properties

    let fiatBalancePresenter: DashboardFiatBalancesPresenter
    let totalBalancePresenter: TotalBalanceViewPresenter
    private(set) lazy var router: DashboardRouter = .init()
    private(set) var announcementCardViewModel: AnnouncementCardViewModel!
    private(set) var fiatBalanceCollectionViewPresenter: CurrencyViewPresenter!
    private(set) var noticeViewModel: NoticeViewModel!
    var sections: Observable<[DashboardViewModel]> {
        sectionsRelay.asObservable()
    }

    // MARK: - Private Properties

    private let accountFetcher: BlockchainAccountFetching
    private let announcementPresenter: AnnouncementPresenting
    private let disposeBag = DisposeBag()
    private let drawerRouter: DrawerRouting
    private let historicalBalanceCellPresenters: [HistoricalBalanceCellPresenter]
    private let interactor: DashboardScreenInteractor
    private let noticePresenter: DashboardNoticePresenter
    private let reloadRelay = BehaviorRelay<Void>(value: ())
    private let sectionsRelay: BehaviorRelay<[DashboardViewModel]> = .init(value: [])

    private var cellArrangement: [DashboardCellType] {
        var items: [DashboardCellType] = [.totalBalance]

        if noticeViewModel != nil {
            items.append(.notice)
        }

        if fiatBalanceCollectionViewPresenter != nil {
            items.append(.fiatCustodialBalances)
        }

        interactor
            .enabledCryptoCurrencies
            .map { DashboardCellType.crypto($0) }
            .forEach { items.append($0) }

        switch announcementCardViewModel?.priority {
        case .high: // Prepend
            items.insert(.announcement, at: 0)
        case .low: // Append
            items.append(.announcement)
        case nil:
            break
        }
        return items
    }

    // MARK: - Init

    init(
        interactor: DashboardScreenInteractor = DashboardScreenInteractor(),
        accountFetcher: BlockchainAccountFetching = resolve(),
        drawerRouter: DrawerRouting = resolve(),
        announcementPresenter: AnnouncementPresenting = resolve(),
        coincore: CoincoreAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.accountFetcher = accountFetcher
        self.interactor = interactor
        self.drawerRouter = drawerRouter
        self.announcementPresenter = announcementPresenter
        totalBalancePresenter = TotalBalanceViewPresenter(
            coincore: coincore,
            fiatCurrencyService: fiatCurrencyService
        )
        noticePresenter = DashboardNoticePresenter()
        historicalBalanceCellPresenters = interactor
            .historicalBalanceInteractors
            .map { .init(interactor: $0) }
        fiatBalancePresenter = DashboardFiatBalancesPresenter(
            interactor: interactor.fiatBalancesInteractor
        )
    }

    // MARK: - Setup

    /// Should be called once the view is loaded
    func setup() {
        // Bind announcements.
        announcementPresenter.announcement
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
            .asObservable()
            .mapToVoid()
            .bindAndCatch(to: reloadRelay)
            .disposed(by: disposeBag)

        // Bind notices.
        noticePresenter.action
            .do(onNext: { action in
                switch action {
                case .hide:
                    self.noticeViewModel = nil
                case .show(let viewModel):
                    self.noticeViewModel = viewModel
                }
            })
            .asObservable()
            .mapToVoid()
            .bindAndCatch(to: reloadRelay)
            .disposed(by: disposeBag)

        // Bind fiat balances.
        fiatBalancePresenter.action
            .do(onNext: { action in
                switch action {
                case .hide:
                    self.fiatBalanceCollectionViewPresenter = nil
                case .show(let presenter):
                    self.fiatBalanceCollectionViewPresenter = presenter
                }
            })
            .asObservable()
            .mapToVoid()
            .bindAndCatch(to: reloadRelay)
            .disposed(by: disposeBag)

        // Bind fiat balances details.
        fiatBalancePresenter
            .tap
            .asObservable()
            .compactMap(\.viewModel)
            .flatMapLatest { [accountFetcher] currencyType in
                accountFetcher
                    .account(for: currencyType, accountType: .nonCustodial)
                    .asObservable()
            }
            .bind { [router] account in
                router.showWalletActionScreen(for: account)
            }
            .disposed(by: disposeBag)

        // Bind fiat balances details.
        reloadRelay
            .throttle(.milliseconds(250), scheduler: MainScheduler.asyncInstance)
            .map(weak: self) { (self, _) in
                self.cellArrangement
            }
            .map(DashboardViewModel.init)
            .map { [$0] }
            .bind(to: sectionsRelay)
            .disposed(by: disposeBag)
    }

    /// Should be called when user pulls-to-refresh.
    func refresh() {
        interactor.refresh()
        announcementPresenter.refresh()
        noticePresenter.refresh()
        fiatBalancePresenter.refresh()
        totalBalancePresenter.refresh()
    }

    /// Given the cell index, returns the historical balance presenter
    func historicalBalancePresenter(by cryptoCurrency: CryptoCurrency) -> HistoricalBalanceCellPresenter {
        historicalBalanceCellPresenters.first { $0.cryptoCurrency == cryptoCurrency }!
    }

    // MARK: - Navigation

    /// Should be invoked upon tapping navigation bar leading button
    func navigationBarLeadingButtonPressed() {
        drawerRouter.toggleSideMenu()
    }
}
