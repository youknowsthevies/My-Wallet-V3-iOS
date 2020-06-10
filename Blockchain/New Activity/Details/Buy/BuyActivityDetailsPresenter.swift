//
//  BuyActivityDetailsPresenter.swift
//  Blockchain
//
//  Created by Paulo on 09/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import Localization
import PlatformKit
import PlatformUIKit
import BuySellKit

final class BuyActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Activity.Details
    private typealias LocalizedLineItem = LocalizationConstants.LineItem.Transactional

    // MARK: - DetailsScreenPresenterAPI

    let buttons: [ButtonViewModel] = []

    let cells: [DetailsScreen.CellType]

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .text(value: LocalizedString.Title.buy))

    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default

    let reloadRelay: PublishRelay<Void> = .init()

    // MARK: - Private Properties

    private let event: BuyActivityItemEvent
    private let interactor: BuyActivityDetailsInteractor
    private let disposeBag: DisposeBag = .init()

    // MARK: Private Properties (Model Relay)

    private let cardDataRelay: BehaviorRelay<CardData?> = .init(value: nil)

    // MARK: Private Properties (LabelContentPresenting)

    private let cryptoAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (LineItemCellPresenting)

    private let orderIDPresenter: LineItemCellPresenting
    private let dateCreatedPresenter: LineItemCellPresenting
    private let totalCostPresenter: LineItemCellPresenting
    private let feePresenter: LineItemCellPresenting
    private let paymentMethodPresenter: LineItemCellPresenting

    // MARK: Private Properties (Badge)

    private let badgesModel: MultiBadgeCellModel = .init()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()

    init(event: BuyActivityItemEvent, interactor: BuyActivityDetailsInteractor = .init()) {
        self.interactor = interactor
        self.event = event

        let paymentMethod: String
        switch event.paymentMethod {
        case .bankTransfer:
            paymentMethod = LocalizedLineItem.bankTransfer
        case .card:
            paymentMethod = LocalizedLineItem.creditOrDebitCard
        }
        let date = DateFormatter.elegantDateFormatter.string(from: event.creationDate)

        orderIDPresenter = TransactionalLineItem.orderId(event.identifier).defaultPresenter()
        dateCreatedPresenter = TransactionalLineItem.date(date).defaultPresenter()
        totalCostPresenter = TransactionalLineItem.totalCost(event.fiatValue.toDisplayString()).defaultPresenter()
        feePresenter = TransactionalLineItem.buyingFee(event.fee.toDisplayString()).defaultPresenter()
        paymentMethodPresenter = TransactionalLineItem.paymentMethod(paymentMethod).defaultPresenter()
        cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            knownValue: event.cryptoValue.toDisplayString(includeSymbol: true),
            descriptors: .h1(accessibilityIdPrefix: Accessibility.Identifier.LineItem.Transactional.cryptoAmount)
        )
        badgesModel.badgesRelay.accept([statusBadge])
        statusBadge.interactor.stateRelay.accept(
            .loaded(next: .init(type: .default, description: event.status.localizedDescription))
        )
        cardDataRelay
            .compactMap { $0 }
            .map { "\($0.label) \($0.displaySuffix)" }
            .map { .loaded(next: .init(text: $0)) }
            .bind(to: paymentMethodPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        cells = [
            .label(cryptoAmountLabelPresenter),
            .badges(badgesModel),
            .lineItem(orderIDPresenter),
            .separator,
            .lineItem(dateCreatedPresenter),
            .separator,
            .lineItem(totalCostPresenter),
            .separator,
            .lineItem(feePresenter),
            .separator,
            .lineItem(paymentMethodPresenter)
        ]
    }

    func viewDidLoad() {
        switch event.paymentMethod {
        case .bankTransfer:
            break
        case .card(let paymentMethodId):
            interactor
                .fetchCardDetails(for: paymentMethodId)
                .asObservable()
                .bind(to: cardDataRelay)
                .disposed(by: disposeBag)
        }
    }
}

fileprivate extension BuyActivityItemEvent.EventStatus {
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.OrderState
    public var localizedDescription: String {
        switch self {
        case .pending:
            return LocalizedString.pending
        case .cancelled:
            return LocalizedString.cancelled
        case .failed:
            return LocalizedString.failed
        case .expired:
            return LocalizedString.expired
        case .finished:
            return LocalizedString.finished
        }
    }
}
