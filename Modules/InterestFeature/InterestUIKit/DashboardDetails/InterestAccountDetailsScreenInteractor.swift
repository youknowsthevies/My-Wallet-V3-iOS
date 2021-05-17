// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import InterestKit
import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

public final class InterestAccountDetailsScreenInteractor {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.AccountDetails.Cell.Default
    private typealias TitleLabelInteractor = DefaultLabelContentInteractor
    private typealias DescriptionLabelInteractor = InterestAccountDetailsDescriptionLabelInteractor
    private typealias CellInteractor = DefaultLineItemCellInteractor

    typealias Interactors = Observable<[DetailCellInteractor]>

    var interactors: Interactors {
        _ = setup
        let items: Interactors = interactorsRelay
            .asObservable()
        let balance: Interactors = Observable.just([.balance(currentBalanceCellInteractor)])
        return Observable
            .combineLatest(balance, items)
            .map { $0.0 + $0.1 }
    }

    private lazy var setup: Void = {
        let rates: CellInteractor = .init(
            title: TitleLabelInteractor(knownValue: LocalizationId.Rate.title),
            description: DescriptionLabelInteractor.Rates.init(
                service: service,
                cryptoCurrency: cryptoCurrency
            )
        )

        let nextPayment: CellInteractor = .init(
            title: TitleLabelInteractor(knownValue: LocalizationId.Next.title),
            description: DescriptionLabelInteractor.NextPayment.init(
                cryptoCurrency: cryptoCurrency)
        )

        let limits: CellInteractor = .init(
            title: TitleLabelInteractor(knownValue: LocalizationId.Hold.title),
            description: DescriptionLabelInteractor.LockUpDuration.init(
                service: service,
                cryptoCurrency: cryptoCurrency
            )
        )

        let total: CellInteractor = .init(
            title: TitleLabelInteractor(knownValue: LocalizationId.Total.title),
            description: DescriptionLabelInteractor.TotalInterest.init(
                service: service,
                cryptoCurrency: cryptoCurrency
            )
        )

        let pending: CellInteractor = .init(
            title: TitleLabelInteractor(knownValue: LocalizationId.Accrued.title),
            description: DescriptionLabelInteractor.PendingDeposit.init(
                service: service,
                cryptoCurrency: cryptoCurrency
            )
        )

        let interactors: [DetailCellInteractor] = [
                total,
                nextPayment,
                pending,
                limits,
                rates
            ]
            .map { .default($0) }
            .map { .item($0) }

        Observable.just(
            interactors
        )
        .bindAndCatch(to: interactorsRelay)
        .disposed(by: disposeBag)
    }()

    let cryptoCurrency: CryptoCurrency
    let currentBalanceCellInteractor: CurrentBalanceCellInteractor

    private let interactorsRelay = BehaviorRelay<[DetailCellInteractor]>(value: [])
    private let service: SavingAccountServiceAPI
    private let disposeBag = DisposeBag()

    public init(service: SavingAccountServiceAPI = resolve(),
                cryptoCurrency: CryptoCurrency,
                assetBalanceFetching: AssetBalanceFetching) {
        self.service = service
        self.cryptoCurrency = cryptoCurrency
        self.currentBalanceCellInteractor = .init(
            balanceFetching: assetBalanceFetching,
            accountType: .custodial(.savings)
        )
    }
}
