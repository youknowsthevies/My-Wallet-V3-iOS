//
//  ERC20ActivityDetailsPresenter.swift
//  Blockchain
//
//  Created by Paulo on 21/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class ERC20ActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Activity.Details

    // MARK: - DetailsScreenPresenterAPI

    let buttons: [ButtonViewModel]

    let cells: [DetailsScreen.CellType]

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default

    let reloadRelay: PublishRelay<Void> = .init()

    // MARK: - Private Properties

    private let interactor: ERC20ActivityDetailsInteractor
    private let event: TransactionalActivityItemEvent
    private let router: ActivityRouterAPI
    private let disposeBag: DisposeBag = .init()
    private let alertViewPresenter: AlertViewPresenterAPI

    // MARK: Private Properties (Model Relay)

    private let itemRelay: BehaviorRelay<ERC20ActivityDetailsViewModel?> = .init(value: nil)

    // MARK: Private Properties (LabelContentPresenting)

    private let cryptoAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (LineItemCellPresenting)

    private let dateCreatedPresenter: LineItemCellPresenting
    private let amountPresenter: LineItemCellPresenting
    private let valuePresenter: LineItemCellPresenting
    private let fromPresenter: LineItemCellPresenting
    private let toPresenter: LineItemCellPresenting
    private let orderIDPresenter: LineItemCellPresenting
    private let feePresenter: LineItemCellPresenting

    // MARK: Private Properties (Badge)

    private let badgesModel: MultiBadgeCellModel = .init()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()
    private let confirmingBadge: DefaultBadgeAssetPresenter = .init()
    private let badgeCircleModel: BadgeCircleViewModel = .init()

    // MARK: Private Properties (Explorer Button)

    private let explorerButton: ButtonViewModel

    init(alertViewPresenter: AlertViewPresenterAPI = AlertViewPresenter.shared,
         event: TransactionalActivityItemEvent,
         router: ActivityRouterAPI,
         interactor: ERC20ActivityDetailsInteractor,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared) {
        self.alertViewPresenter = alertViewPresenter
        self.event = event
        self.interactor = interactor
        self.router = router
        explorerButton = .secondary(with: LocalizedString.Button.viewOnExplorer)
        buttons = [ explorerButton ]
        dateCreatedPresenter = TransactionalLineItem.date().defaultPresenter()
        amountPresenter = TransactionalLineItem.amount().defaultPresenter()
        valuePresenter = TransactionalLineItem.value().defaultPresenter()
        feePresenter = TransactionalLineItem.fee().defaultPresenter()
        fromPresenter = TransactionalLineItem.from().defaultCopyablePresenter(analyticsRecorder: analyticsRecorder)
        toPresenter = TransactionalLineItem.to().defaultCopyablePresenter(analyticsRecorder: analyticsRecorder)
        orderIDPresenter = TransactionalLineItem.orderId(event.identifier).defaultCopyablePresenter(analyticsRecorder: analyticsRecorder)
        cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            descriptors: .h1(accessibilityIdPrefix: Accessibility.Identifier.LineItem.Transactional.cryptoAmount)
        )
        cells = [
            .label(cryptoAmountLabelPresenter),
            .badges(badgesModel),
            .separator,
            .lineItem(orderIDPresenter),
            .separator,
            .lineItem(dateCreatedPresenter),
            .separator,
            .lineItem(amountPresenter),
            .separator,
            .lineItem(valuePresenter),
            .separator,
            .lineItem(feePresenter),
            .separator,
            .lineItem(fromPresenter),
            .separator,
            .lineItem(toPresenter)
        ]
        bindAll(event: event)
    }

    func viewDidLoad() {
        interactor
            .details(identifier: event.identifier, createdAt: event.creationDate)
            .subscribe(
                onNext: { [weak self] model in
                    self?.itemRelay.accept(model)
                },
                onError: { [weak self] _ in
                    self?.alertViewPresenter.error(in: nil, action: nil)
                }
            )
            .disposed(by: disposeBag)
    }

    func bindAll(event: TransactionalActivityItemEvent) {
        let title: String
        switch event.type {
        case .send:
            title = LocalizedString.Title.send
        case .receive:
            title = LocalizedString.Title.receive
        }
        titleViewRelay.accept(.text(value: title))

        explorerButton
            .tapRelay
            .bind { [weak self] in
                self?.router.showBlockchainExplorer(for: event)
            }
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.confirmation.factor }
            .bind(to: badgeCircleModel.fillRatioRelay)
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.confirmation.title }
            .distinctUntilChanged()
            .map(weak: self) { (self, confirmation) in
                .loaded(next: .init(type: .progress(self.badgeCircleModel), description: confirmation))
            }
            .bind(to: confirmingBadge.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.confirmation.needConfirmation }
            .distinctUntilChanged()
            .map(weak: self) { (self, needConfirmation) in
                needConfirmation ? [ self.statusBadge, self.confirmingBadge ] : [ self.statusBadge ]
            }
            .bind(to: badgesModel.badgesRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amounts.gasFor?.cryptoAmount }
            .mapToLabelContentStateInteraction()
            .bind(to: cryptoAmountLabelPresenter.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.dateCreated }
            .mapToLabelContentStateInteraction()
            .bind(to: dateCreatedPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amounts.gasFor?.amount }
            .mapToLabelContentStateInteraction()
            .bind(to: amountPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amounts.gasFor?.value }
            .mapToLabelContentStateInteraction()
            .bind(to: valuePresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.from }
            .mapToLabelContentStateInteraction()
            .bind(to: fromPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.to }
            .mapToLabelContentStateInteraction()
            .bind(to: toPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.confirmation.statusBadge }
            .map { .loaded(next: $0) }
            .bind(to: statusBadge.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amounts.fee.cryptoAmount }
            .mapToLabelContentStateInteraction()
            .bind(to: feePresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .distinctUntilChanged()
            .mapToVoid()
            .bind(to: reloadRelay)
            .disposed(by: disposeBag)
    }
}
