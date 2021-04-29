// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public final class PortfolioSyncingService: BalanceSharingSettingsServiceAPI {
    
    // MARK: - Setup
    
    private lazy var setup: Void = {
        balanceSyncRelay
            .flatMap(weak: self) { (self, _) -> Observable<Bool> in
                self.isEnabled
            }
            .flatMap(weak: self) { (self, value) -> Observable<Portfolio?> in
                guard value else { return .just(nil) }
                return self.portfolioProviding
                        .portfolio
                        .optional()
            }
            .catchErrorJustReturn(nil)
            .bindAndCatch(to: container.portfolioRelay)
            .disposed(by: disposeBag)
    }()
    
    // MARK: - Private Properties
    
    private let balanceSyncRelay = PublishRelay<Void>()
    private let container: SharedContainerUserDefaults
    private let portfolioProviding: PortfolioProviding
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    public init(sharedContainerUserDefaults: SharedContainerUserDefaults = SharedContainerUserDefaults.default,
                balanceProviding: BalanceProviding,
                balanceChangeProviding: BalanceChangeProviding,
                fiatCurrencyProviding: FiatCurrencyServiceAPI) {
        self.portfolioProviding = PortfolioProvider(
            balanceProviding: balanceProviding,
            balanceChangeProviding: balanceChangeProviding,
            fiatCurrencyProviding: fiatCurrencyProviding
        )
        self.container = sharedContainerUserDefaults
    }
    
    // MARK: - BalanceSharingSettingsServiceAPI
    
    public var isEnabled: Observable<Bool> {
        container
            .portfolioSyncEnabled
            .distinctUntilChanged()
    }
    
    public func sync() {
        _ = setup
        balanceSyncRelay.accept(())
    }
    
    public func balanceSharing(enabled: Bool) -> Completable {
        Completable.create { [weak self] observer -> Disposable in
            guard let self = self else {
                observer(.completed)
                return Disposables.create()
            }
            self.container.shouldSyncPortfolio = enabled
            observer(.completed)
            return Disposables.create()
        }
    }
}
