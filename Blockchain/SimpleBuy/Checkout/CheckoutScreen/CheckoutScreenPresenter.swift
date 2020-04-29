//
//  CheckoutScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/23/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class CheckoutScreenPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout
    private typealias AccessibilityId = Accessibility.Identifier.LineItem

    // MARK: - Navigation Properties

    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    var titleView: Screen.Style.TitleView {
        .text(value: contentReducer.title)
    }

    // MARK: - Screen Properties

    private(set) var buttons: [ButtonViewModel] = []

    var cells: [DetailsScreen.CellType] {
        contentReducer.cells
    }

    // MARK: - Injected
    
    private let analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording
    private let alertPresenter: AlertViewPresenter
    private let loadingViewPresenter: LoadingViewPresenting
    private let interactor: CheckoutScreenInteractor
    private unowned let stateService: SimpleBuyConfirmCheckoutServiceAPI

    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    private let contentReducer: ContentReducer

    // MARK: - Setup
    
    init(stateService: SimpleBuyConfirmCheckoutServiceAPI,
         alertPresenter: AlertViewPresenter = .shared,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared,
         interactor: CheckoutScreenInteractor) {
        self.analyticsRecorder = analyticsRecorder
        self.stateService = stateService
        self.loadingViewPresenter = loadingViewPresenter
        self.alertPresenter = alertPresenter
        self.interactor = interactor
        let data = interactor.checkoutData

        // MARK: Content Reducer

        contentReducer = ContentReducer(data: data)

        // MARK: Buttons Setup

        contentReducer.continueButtonViewModel
            .tapRelay
            .show(loader: loadingViewPresenter, style: .circle)
            .flatMap(weak: self) { (self, _) in
                self.interactor.continue()
                    .mapToResult()
            }
            .hide(loader: loadingViewPresenter)
            .bind(weak: self) { (self, result) in
                switch result {
                case .success(let data):
                    self.stateService.confirmCheckout(with: data)
                case .failure:
                    self.alertPresenter.error()
                }
            }
            .disposed(by: disposeBag)
        
        contentReducer.continueButtonViewModel
            .tapRelay
            .map { _ in AnalyticsEvent.sbCheckoutConfirm }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
        
        contentReducer.cancelButtonViewModel?
            .tapRelay
            .bind(weak: self) { (self) in
                self.cancel()
            }
            .disposed(by: disposeBag)
        
        contentReducer.cancelButtonViewModel?
            .tapRelay
            .map { _ in AnalyticsEvent.sbCheckoutCancel }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)

        buttons.append(contentReducer.continueButtonViewModel)
        if let cancelButtonViewModel = contentReducer.cancelButtonViewModel {
            buttons.append(cancelButtonViewModel)
        }

    }
    
    /// Should get called once, when the view has finished loading
    func viewDidLoad() {
        interactor.setup()
            .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
            .subscribe(
                onSuccess: { [weak self] data in
                    self?.setupDidSucceed(with: data)
                },
                onError: { [weak self] _ in
                    self?.setupDidFail()
                }
            )
            .disposed(by: disposeBag)
        
        analyticsRecorder.record(event: AnalyticsEvent.sbCheckoutShown)
    }
    
    private func cancel() {
        interactor.cancelIfPossible()
            .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
            .subscribe(
                onSuccess: { [weak self] wasCancelled in
                    guard let self = self else { return }
                    if wasCancelled {
                        self.analyticsRecorder.record(event: AnalyticsEvent.sbCheckoutCancelGoBack)
                    }
                    self.stateService.previousRelay.accept(())
                }
            )
            .disposed(by: disposeBag)
    }
    
    // MARK: - Navigation

    func navigationBarLeadingButtonPressed() {
        cancel()
    }

    func navigationBarTrailingButtonPressed() {
        stateService.previousRelay.accept(())
    }

    // MARK: - Accessors
    
    private func setupDidSucceed(with data: CheckoutScreenInteractor.InteractionData) {
        let time = DateFormatter.elegantDateFormatter.string(from: data.time)
        contentReducer.dateLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: time))
        )
        contentReducer.buyingFeeLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: data.fee.toDisplayString()))
        )
        
        let amount = "~ \(data.amount.toDisplayString(includeSymbol: true))"
        contentReducer.amountLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: amount))
        )
        contentReducer.exchangeRateLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: data.exchangeRate.toDisplayString(includeSymbol: true)))
        )
        contentReducer.orderIdLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: data.orderId))
        )
        
        let localizedPaymentMethod: String
        if let card = data.card {
            localizedPaymentMethod = "\(card.label) \(card.displaySuffix)"
        } else {
            localizedPaymentMethod = LocalizationConstants.SimpleBuy.Checkout.LineItem.bankTransfer
        }
        contentReducer.paymentMethodLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: localizedPaymentMethod))
        )
    }
    
    /// Is called as the interaction setup fails
    private func setupDidFail() {
        alertPresenter.error { [weak stateService] in
            stateService?.previousRelay.accept(())
        }
    }
}

extension CheckoutScreenPresenter {

    // MARK: - Content Reducer

    final class ContentReducer {

        let title: String
        let cells: [DetailsScreen.CellType]

        // MARK: - View Models

        let continueButtonViewModel: ButtonViewModel
        let cancelButtonViewModel: ButtonViewModel?

        // MARK: - Cell Presenters

        let orderIdLineItemCellPresenter: DefaultLineItemCellPresenter
        let dateLineItemCellPresenter: DefaultLineItemCellPresenter
        let totalCostLineItemCellPresenter: DefaultLineItemCellPresenter
        let amountLineItemCellPresenter: DefaultLineItemCellPresenter
        let buyingFeeLineItemCellPresenter: DefaultLineItemCellPresenter
        let paymentMethodLineItemCellPresenter: DefaultLineItemCellPresenter
        let exchangeRateLineItemCellPresenter: DefaultLineItemCellPresenter
        let statusLineItemCellPresenter: DefaultLineItemCellPresenter

        init(data: SimpleBuyCheckoutData) {

            // MARK: Presenters Setup

            buyingFeeLineItemCellPresenter = CheckoutCellType.LineItemType.buyingFee(nil).defaultPresenter()
            dateLineItemCellPresenter = CheckoutCellType.LineItemType.date(nil).defaultPresenter()
            exchangeRateLineItemCellPresenter = CheckoutCellType.LineItemType.exchangeRate(nil).defaultPresenter()
            orderIdLineItemCellPresenter = CheckoutCellType.LineItemType.orderId(nil).defaultPresenter()
            paymentMethodLineItemCellPresenter = CheckoutCellType.LineItemType.paymentMethod(nil).defaultPresenter()
            statusLineItemCellPresenter = CheckoutCellType.LineItemType.orderId(LocalizedString.LineItem.pending).defaultPresenter()
            totalCostLineItemCellPresenter = CheckoutCellType.LineItemType.totalCost(data.fiatValue.toDisplayString()).defaultPresenter()

            let amount: CheckoutCellType.LineItemType = data.hasCheckoutMade ? .amount(nil) : .estimatedAmount(nil)
            amountLineItemCellPresenter = amount.defaultPresenter()

            // MARK: Disclaimer Setup

            let notice: String
            switch data.detailType.paymentMethod {
            case .card:
                notice = LocalizedString.cardNotice
            case .bankTransfer:
                notice = "\(LocalizedString.BankNotice.prefix) \(data.cryptoCurrency.displayCode) \(LocalizedString.BankNotice.suffix)"
            }
            let noticeViewModel = NoticeViewModel(
                imageViewContent: .init(
                    imageName: "disclaimer-icon",
                    accessibility: .id(AccessibilityId.disclaimerImage),
                    bundle: .platformUIKit
                ),
                labelContent: .init(
                    text: notice,
                    font: .main(.medium, 12),
                    color: .descriptionText,
                    accessibility: .id(AccessibilityId.disclaimerLabel)
                ),
                verticalAlignment: .top
            )

            typealias LocalizedSummary = LocalizedString.Summary
            if data.hasCheckoutMade {

                // MARK: Title Setup

                title = LocalizedString.Title.orderDetails

                // MARK: Buttons Setup

                continueButtonViewModel = .primary(
                    with: data.isPending3DS ? LocalizedSummary.completePaymentButton : LocalizedSummary.continueButtonPrefix
                )
                cancelButtonViewModel = nil

                // MARK: Cells Setup

                let lineItems = [
                    orderIdLineItemCellPresenter,
                    dateLineItemCellPresenter,
                    amountLineItemCellPresenter,
                    exchangeRateLineItemCellPresenter,
                    paymentMethodLineItemCellPresenter,
                    buyingFeeLineItemCellPresenter,
                    totalCostLineItemCellPresenter,
                    statusLineItemCellPresenter
                    ]
                    .map { DetailsScreen.CellType.lineItem($0) }

                cells = [ .separator ] + lineItems + [ .separator, .notice(noticeViewModel) ]
            } else {

                // MARK: Title Setup

                title = LocalizedString.Title.checkout

                // MARK: Buttons Setup

                continueButtonViewModel = .primary(
                    with: "\(LocalizedSummary.buyButtonPrefix)\(data.cryptoCurrency.displayCode)"
                )
                cancelButtonViewModel = .cancel(with: LocalizationConstants.cancel)

                // MARK: Cells Setup
    
                let summary = LabelContent(
                    text: "\(LocalizedSummary.Title.prefix)\(data.cryptoCurrency.displayCode)\(LocalizedSummary.Title.suffix)",
                    font: .main(.medium, 14.0),
                    color: .descriptionText,
                    accessibility: .id(AccessibilityId.descriptionLabel)
                )

                let lineItems = [
                    orderIdLineItemCellPresenter,
                    dateLineItemCellPresenter,
                    totalCostLineItemCellPresenter,
                    amountLineItemCellPresenter,
                    buyingFeeLineItemCellPresenter,
                    paymentMethodLineItemCellPresenter,
                    buyingFeeLineItemCellPresenter
                    ]
                    .map { DetailsScreen.CellType.lineItem($0) }

                cells = [ .label(summary), .separator ] + lineItems + [ .separator, .notice(noticeViewModel) ]
            }
        }
    }

}
