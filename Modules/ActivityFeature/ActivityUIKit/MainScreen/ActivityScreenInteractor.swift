// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ActivityKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class ActivityScreenInteractor {

    typealias State = ValueCalculationState<[ActivityItemInteractor]>

    // MARK: - Public Properties

    var fiatCurrency: Observable<FiatCurrency> {
        serviceContainer
            .fiatCurrency
            .fiatCurrencyObservable
    }

    var selectedData: Observable<BlockchainAccount> {
        selectionService
            .selectedData
    }

    var activityBalance: Observable<FiatValue> {
        fiatCurrency
            .withLatestFrom(selectionService.selectedData) { (fiatCurrency: $0, account: $1) }
            .flatMapLatest { (fiatCurrency: FiatCurrency, account: BlockchainAccount) in
                account.fiatBalance(fiatCurrency: fiatCurrency)
                    .compactMap(\.fiatValue)
                    .catchErrorJustReturn(.zero(currency: fiatCurrency))
            }
    }

    var state: Observable<State> {
        stateRelay
            .asObservable()
    }

    var isEmpty: Observable<Bool> {
        stateRelay
            .asObservable()
            .map { value in
                switch value {
                case .invalid(let error):
                    return error == .empty
                case .value(let values):
                    return values.count == 0
                case .calculating:
                    return false
                }
        }
    }

    // MARK: - Private Properties

    private var selectionService: WalletPickerSelectionServiceAPI {
        serviceContainer.selectionService
    }

    private let stateRelay = BehaviorRelay<State>(value: .invalid(.empty))
    private let serviceContainer: ActivityServiceContaining
    private let disposeBag = DisposeBag()

    init(serviceContainer: ActivityServiceContaining) {
        self.serviceContainer = serviceContainer

        serviceContainer
            .activityEventsLoadingState
            .map {
                State(
                    with: $0,
                    exchangeProviding: serviceContainer.exchangeProviding,
                    balanceProviding: serviceContainer.balanceProviding
                )
            }
            .startWith(.calculating)
            .catchErrorJustReturn(.invalid(.empty))
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }

    func refresh() {
        serviceContainer.activityProviding.refresh()
    }
}

fileprivate extension ActivityScreenInteractor.State {

    /// Initializer that receives the loading state and
    /// maps it to `self`
    init(with state: ActivityItemEventsLoadingState,
         exchangeProviding: ExchangeProviding,
         balanceProviding: BalanceProviding) {
        switch state {
        case .loading:
            self = .calculating
        case .loaded(let value):
            let sorted = value.sorted(by: { $0.creationDate.compare($1.creationDate) == .orderedDescending })
            let interactors: [ActivityItemInteractor] = sorted.map {
                ActivityItemInteractor(
                    exchangeAPI: exchangeProviding[$0.amount.currencyType],
                    assetBalanceFetcher: balanceProviding[$0.amount.currencyType],
                    activityItemEvent: $0
                )
            }
            self = interactors.count > 0 ? .value(interactors) : .invalid(.empty)
        }
    }
}
