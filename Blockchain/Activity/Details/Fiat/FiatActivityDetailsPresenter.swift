//
//  FiatActivityDetailsPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/31/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class FiatActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias BadgeItem = BadgeAsset.Value.Interaction.BadgeItem
    private typealias BadgeType = BadgeItem.BadgeType
    private typealias LocalizedString = LocalizationConstants.Activity.Details
    private typealias AccessibilityId = Accessibility.Identifier.Activity.Details

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

    private let fiatAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (LineItemCellPresenting)

    private let dateCreatedPresenter: LineItemCellPresenting
    private let orderIDPresenter: LineItemCellPresenting

    // MARK: Private Properties (Badge Model)

    private let badgesModel: MultiBadgeCellModel = .init()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()

    // MARK: - Init

    init(event: FiatActivityItemEvent,
         analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        fiatAmountLabelPresenter = DefaultLabelContentPresenter(
            knownValue: event.fiatValue.toDisplayString(includeSymbol: true),
            descriptors: .h1(accessibilityIdPrefix: "")
        )
        dateCreatedPresenter = TransactionalLineItem.date(DateFormatter.elegantDateFormatter.string(from: event.date))
            .defaultPresenter(accessibilityIdPrefix: AccessibilityId.lineItemPrefix)
        orderIDPresenter = TransactionalLineItem.orderId(event.identifier).defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        titleViewRelay
            .accept(.text(value: LocalizedString.Title.deposit))
        var statusDescription = event.status.rawValue
        switch event.status {
        case .complete,
             .cleared:
            statusDescription = LocalizedString.completed
        case .pending,
             .fraudReview,
             .manualReview,
             .unidentified,
             .created:
            statusDescription = LocalizedString.pending
        case .failed,
             .rejected:
            statusDescription = LocalizedString.failed
        case .refunded:
            statusDescription = LocalizedString.refunded
        }
        
        let badgeType: BadgeType = event.status == .complete ? .verified : .default(accessibilitySuffix: statusDescription)
        let badgeItem: BadgeItem = .init(
            type: badgeType,
            description: statusDescription
        )
        statusBadge
            .interactor
            .stateRelay
            .accept(
                .loaded(
                    next: badgeItem
                )
        )
        badgesModel
            .badgesRelay
            .accept([statusBadge])

        cells = [
            .label(fiatAmountLabelPresenter),
            .badges(badgesModel),
            .separator,
            .lineItem(orderIDPresenter),
            .separator,
            .lineItem(dateCreatedPresenter)
        ]
    }
}

