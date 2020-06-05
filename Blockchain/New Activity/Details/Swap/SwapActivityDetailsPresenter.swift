//
//  SwapActivityDetailsPresenter.swift
//  Blockchain
//
//  Created by Paulo on 20/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class SwapActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Activity.Details

    // MARK: - DetailsScreenPresenterAPI

    let cells: [DetailsScreen.CellType]

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default

    let reloadRelay: PublishRelay<Void> = .init()

    // MARK: - Private Properties

    private let disposeBag: DisposeBag = .init()

    // MARK: Private Properties (LabelContentPresenting)

    private let cryptoAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (LineItemCellPresenting)

    private let dateCreatedPresenter: LineItemCellPresenting
    private let valuePresenter: LineItemCellPresenting
    private let amountFromPresenter: LineItemCellPresenting
    private let amountForPresenter: LineItemCellPresenting
    private let toPresenter: LineItemCellPresenting
    private let orderIDPresenter: LineItemCellPresenting

    // MARK: Private Properties (Badge Model)

    private let badgesModel: MultiBadgeCellModel = .init()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()

    // MARK: - Init

    init(event: SwapActivityItemEvent,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared) {
        cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            knownValue: event.amounts.withdrawal.toDisplayString(includeSymbol: true),
            descriptors: .h1(accessibilityIdPrefix: Accessibility.Identifier.LineItem.Transactional.cryptoAmount)
        )
        dateCreatedPresenter = TransactionalLineItem
            .date(DateFormatter.elegantDateFormatter.string(from: event.date))
            .defaultPresenter()
        valuePresenter = TransactionalLineItem
            .value(event.amounts.fiatValue.toDisplayString())
            .defaultPresenter()
        amountFromPresenter = TransactionalLineItem
            .amount(event.amounts.deposit.toDisplayString(includeSymbol: true))
            .defaultPresenter()
        amountForPresenter = TransactionalLineItem
            .for(event.amounts.withdrawal.toDisplayString(includeSymbol: true))
            .defaultPresenter()
        orderIDPresenter = TransactionalLineItem
            .orderId(event.identifier)
            .defaultCopyablePresenter(analyticsRecorder: analyticsRecorder)
        toPresenter = TransactionalLineItem
            .to(event.addresses.withdrawalAddress)
            .defaultCopyablePresenter(analyticsRecorder: analyticsRecorder)

        titleViewRelay
            .accept(.text(value: LocalizedString.Title.swap))
        statusBadge
            .interactor
            .stateRelay
            .accept(
                .loaded(
                    next: .init(type: event.status == .complete ? .verified : .default, description: event.status.localizedDescription)
                )
        )
        badgesModel
            .badgesRelay
            .accept([statusBadge])

        cells = [
            .label(cryptoAmountLabelPresenter),
            .badges(badgesModel),
            .separator,
            .lineItem(orderIDPresenter),
            .separator,
            .lineItem(dateCreatedPresenter),
            .separator,
            .lineItem(amountFromPresenter),
            .separator,
            .lineItem(amountForPresenter),
            .separator,
            .lineItem(valuePresenter),
            .separator,
            .lineItem(toPresenter),
            .separator
        ]
    }
}
