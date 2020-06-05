//
//  StellarActivityDetailsPresenter.swift
//  Blockchain
//
//  Created by Paulo on 19/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class StellarActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Activity.Details

    // MARK: - DetailsScreenPresenterAPI

    let buttons: [ButtonViewModel]

    var cells: [DetailsScreen.CellType] = []

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default

    let reloadRelay: PublishRelay<Void> = .init()
    
    // MARK: - Private Accessors
    
    private var baseCells: [DetailsScreen.CellType] {
        [
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
            .separator
        ]
    }

    private var sendCells: [DetailsScreen.CellType] {
        baseCells + [
            .lineItem(feePresenter),
            .separator,
            .lineItem(fromPresenter),
            .separator,
            .lineItem(toPresenter),
            .separator,
            .lineItem(memoPresenter)
        ]
    }

    private var receiveCells: [DetailsScreen.CellType] {
        baseCells + [
            .lineItem(fromPresenter),
            .separator,
            .lineItem(toPresenter),
            .separator,
            .lineItem(memoPresenter)
        ]
    }

    // MARK: - Private Properties
    
    private let interactor: StellarActivityDetailsInteractor
    private let router: ActivityRouterAPI
    private let disposeBag: DisposeBag = .init()
    private let event: TransactionalActivityItemEvent
    private let alertViewPresenter: AlertViewPresenterAPI

    // MARK: Private Properties (Model Relay)

    private let itemRelay: BehaviorRelay<StellarActivityDetailsViewModel?> = .init(value: nil)

    // MARK: Private Properties (LabelContentPresenting)

    private let cryptoAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (LineItemCellPresenting)

    private let dateCreatedPresenter: LineItemCellPresenting
    private let amountPresenter: LineItemCellPresenting
    private let valuePresenter: LineItemCellPresenting
    private let fromPresenter: LineItemCellPresenting
    private let toPresenter: LineItemCellPresenting
    private let orderIDPresenter: LineItemCellPresenting
    private let memoPresenter: LineItemCellPresenting
    private let feePresenter: LineItemCellPresenting

    // MARK: Private Properties (Badge)

    private let badgesModel: MultiBadgeCellModel = .init()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()

    // MARK: Private Properties (Explorer Button)

    private let explorerButton: ButtonViewModel

    // MARK: - Init

    init(alertViewPresenter: AlertViewPresenterAPI = AlertViewPresenter.shared,
         event: TransactionalActivityItemEvent,
         router: ActivityRouterAPI,
         interactor: StellarActivityDetailsInteractor = .init(),
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared) {
        precondition(event.currency == .stellar, "Using StellarActivityDetailsPresenter with \(event.currency) event.")
        self.alertViewPresenter = alertViewPresenter
        self.event = event
        self.router = router
        self.interactor = interactor
        explorerButton = .secondary(with: LocalizedString.Button.viewOnStellarChainIO)
        buttons = [ explorerButton ]
        dateCreatedPresenter = TransactionalLineItem.date().defaultPresenter()
        amountPresenter = TransactionalLineItem.amount().defaultPresenter()
        valuePresenter = TransactionalLineItem.value().defaultPresenter()
        fromPresenter = TransactionalLineItem.from().defaultCopyablePresenter(analyticsRecorder: analyticsRecorder)
        toPresenter = TransactionalLineItem.to().defaultCopyablePresenter(analyticsRecorder: analyticsRecorder)
        feePresenter = TransactionalLineItem.fee().defaultPresenter()
        memoPresenter = TransactionalLineItem.memo().defaultPresenter()
        orderIDPresenter = TransactionalLineItem.orderId().defaultCopyablePresenter(analyticsRecorder: analyticsRecorder)
        cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            descriptors: .h1(accessibilityIdPrefix: Accessibility.Identifier.LineItem.Transactional.cryptoAmount)
        )
        let title: String
        switch event.type {
        case .send:
            title = LocalizedString.Title.send
            cells = sendCells
        case .receive:
            title = LocalizedString.Title.receive
            cells = receiveCells
        }
        titleViewRelay.accept(.text(value: title))
        bindAll(with: event)
    }
    
    // MARK: - Public Functions

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

    func bindAll(with event: TransactionalActivityItemEvent) {
        explorerButton
            .tapRelay
            .bind { [weak self] item in
                self?.router.showBlockchainExplorer(for: event)
            }
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.transactionHash }
            .mapToLabelContentStateInteraction()
            .bind(to: orderIDPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.statusBadge }
            .distinctUntilChanged()
            .map(weak: self) { (self, _) in
                [self.statusBadge]
            }
            .bind(to: badgesModel.badgesRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.cryptoAmount }
            .mapToLabelContentStateInteraction()
            .bind(to: cryptoAmountLabelPresenter.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.dateCreated }
            .mapToLabelContentStateInteraction()
            .bind(to: dateCreatedPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amount }
            .mapToLabelContentStateInteraction()
            .bind(to: amountPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.value }
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
            .compactMap { $0?.statusBadge }
            .distinctUntilChanged()
            .map { .loaded(next: $0) }
            .bind(to: statusBadge.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.memo }
            .mapToLabelContentStateInteraction()
            .bind(to: memoPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.fee }
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
