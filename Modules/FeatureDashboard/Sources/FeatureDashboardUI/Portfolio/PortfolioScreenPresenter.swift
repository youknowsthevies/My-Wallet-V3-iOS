// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class PortfolioScreenPresenter {

    struct Model {
        let historicalBalanceCellPresenters: [HistoricalBalanceCellPresenter]
        let totalBalancePresenter: TotalBalanceViewPresenter
        var announcementCardViewModel: AnnouncementCardViewModel?
        var fiatBalanceCollectionViewPresenter: CurrencyViewPresenter?
        var cryptoCurrencies: [CryptoCurrency: Bool] = [:]

        var cellArrangement: [PortfolioCellType] {
            var items: [PortfolioCellType] = [.totalBalance(totalBalancePresenter)]

            if let fiatBalanceCollectionViewPresenter = fiatBalanceCollectionViewPresenter {
                items.append(.fiatCustodialBalances(fiatBalanceCollectionViewPresenter))
            }

            let enabledCryptoCurrencies = cryptoCurrencies
                .filter(\.value)
                .map(\.key)
                .sorted()
            enabledCryptoCurrencies
                .compactMap { cryptoCurrency in
                    historicalBalanceCellPresenters.first(where: { $0.cryptoCurrency == cryptoCurrency })
                }
                .map(PortfolioCellType.crypto)
                .forEach { items.append($0) }

            if enabledCryptoCurrencies.isEmpty {
                Array(1...7)
                    .map(PortfolioCellType.cryptoSkeleton)
                    .forEach { items.append($0) }
            }

            if let announcementCardViewModel = announcementCardViewModel {
                switch announcementCardViewModel.priority {
                case .high: // Prepend
                    items.insert(.announcement(announcementCardViewModel), at: 0)
                case .low: // Append
                    items.append(.announcement(announcementCardViewModel))
                }
            }
            return items
        }
    }

    // MARK: - Internal Properties

    /// Should be triggered when user pulls-to-refresh.
    let refreshRelay = BehaviorRelay<Void>(value: ())
    let fiatBalancePresenter: DashboardFiatBalancesPresenter
    var model: Model
    private(set) lazy var router: PortfolioRouter = .init()
    var sections: Observable<[PortfolioViewModel]> {
        sectionsRelay.asObservable()
    }

    // MARK: - Private Properties

    private let accountFetcher: BlockchainAccountFetching
    private let announcementPresenter: AnnouncementPresenting
    private let disposeBag = DisposeBag()
    private let drawerRouter: DrawerRouting
    private let interactor: PortfolioScreenInteractor
    private let internalFeatureFlagService: InternalFeatureFlagServiceAPI
    private let reloadRelay: PublishRelay<Void> = .init()
    private let sectionsRelay: BehaviorRelay<[PortfolioViewModel]> = .init(value: [])
    private let coincore: CoincoreAPI

    private var cryptoCurrencies: Observable<CryptoCurrency> {
        guard internalFeatureFlagService.isEnabled(.splitDashboard) else {
            return .from(interactor.enabledCryptoCurrencies, scheduler: MainScheduler.asyncInstance)
        }
        let cryptoStreams: [Observable<CryptoCurrency?>] = coincore.cryptoAssets
            .map { asset -> Observable<CryptoCurrency?> in
                asset.accountGroup(filter: .all)
                    .asObservable()
                    .asSingle()
                    .flatMap { group -> Single<Bool> in
                        group.balance.map(\.isPositive)
                    }
                    .map { hasBalance -> CryptoCurrency? in
                        hasBalance ? asset.asset : nil
                    }
                    .asObservable()
                    .startWith(nil)
                    .catchErrorJustReturn(nil)
            }
        return Observable
            .merge(cryptoStreams)
            .compactMap { $0 }
    }

    // MARK: - Init

    init(
        interactor: PortfolioScreenInteractor = PortfolioScreenInteractor(),
        accountFetcher: BlockchainAccountFetching = resolve(),
        drawerRouter: DrawerRouting = resolve(),
        announcementPresenter: AnnouncementPresenting = resolve(),
        coincore: CoincoreAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        internalFeatureFlagService: InternalFeatureFlagServiceAPI = resolve()
    ) {
        self.accountFetcher = accountFetcher
        self.announcementPresenter = announcementPresenter
        self.coincore = coincore
        self.drawerRouter = drawerRouter
        self.interactor = interactor
        self.internalFeatureFlagService = internalFeatureFlagService
        fiatBalancePresenter = DashboardFiatBalancesPresenter(
            interactor: interactor.fiatBalancesInteractor
        )
        let totalBalancePresenter = TotalBalanceViewPresenter(
            coincore: coincore,
            fiatCurrencyService: fiatCurrencyService
        )
        let historicalBalanceCellPresenters = interactor
            .historicalBalanceInteractors
            .map(HistoricalBalanceCellPresenter.init)
        model = Model(
            historicalBalanceCellPresenters: historicalBalanceCellPresenters,
            totalBalancePresenter: totalBalancePresenter
        )
    }

    // MARK: - Setup

    /// Should be called once the view is loaded
    func setup() {
        // Bind announcements.
        announcementPresenter.announcement
            .do(onNext: { [weak self] action in
                switch action {
                case .hide:
                    self?.model.announcementCardViewModel = nil
                case .show(let viewModel):
                    self?.model.announcementCardViewModel = viewModel
                case .none:
                    break
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
                    self.model.fiatBalanceCollectionViewPresenter = nil
                case .show(let presenter):
                    self.model.fiatBalanceCollectionViewPresenter = presenter
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

        reloadRelay
            .startWith(())
            .throttle(.milliseconds(250), scheduler: MainScheduler.asyncInstance)
            .map(weak: self) { (self, _) in
                self.model.cellArrangement
            }
            .map(PortfolioViewModel.init)
            .map { [$0] }
            .bind(to: sectionsRelay)
            .disposed(by: disposeBag)

        refreshRelay
            .throttle(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] _ in
                self?.interactor.refresh()
                self?.announcementPresenter.refresh()
                self?.fiatBalancePresenter.refresh()
                self?.model.totalBalancePresenter.refresh()
            }
            .disposed(by: disposeBag)

        refreshRelay
            .throttle(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .flatMapLatest(weak: self) { (self, _) in
                self.cryptoCurrencies
            }
            .do(onNext: { [weak self] cryptoCurrency in
                self?.model.cryptoCurrencies[cryptoCurrency] = true
            })
            .mapToVoid()
            .bindAndCatch(to: reloadRelay)
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation

    /// Should be invoked upon tapping navigation bar leading button
    func navigationBarLeadingButtonPressed() {
        drawerRouter.toggleSideMenu()
    }
}
