//
//  CheckoutScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/23/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import RxRelay
import ToolKit
import PlatformKit
import PlatformUIKit

final class CheckoutScreenPresenter {

    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout
    private typealias AccessibilityId = Accessibility.Identifier.LineItem
        
    // MARK: - Navigation Bar Properties
    
    var titleView: Screen.Style.TitleView { .text(value: title) }

    /// Returns the ordered cell types
    let cellArrangement: [CheckoutCellType]
    
    // MARK: - View Models / Presenters
    
    private(set) var summaryLabelContent: LabelContent?
    let noticeViewModel: NoticeViewModel
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

    // MARK: - Injected
    
    private let analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording
    private let alertPresenter: AlertViewPresenter
    private let loadingViewPresenter: LoadingViewPresenting
    
    private let interactor: CheckoutScreenInteractor
    private unowned let stateService: SimpleBuyConfirmCheckoutServiceAPI

    private let title: String
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
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
        
        let amountLineTitle: String
        
        if data.hasCheckoutMade {
            title = LocalizedString.Title.orderDetails
            amountLineTitle = LocalizedString.LineItem.amount
            cellArrangement = [
                .separator,
                .lineItem(.orderId),
                .lineItem(.date),
                .lineItem(.amount),
                .lineItem(.exchangeRate),
                .lineItem(.paymentMethod),
                .lineItem(.buyingFee),
                .lineItem(.totalCost),
                .lineItem(.status),
                .separator,
                .disclaimer
            ]
        } else {
            title = LocalizedString.Title.checkout
            amountLineTitle = LocalizedString.LineItem.estimatedAmount
            typealias TitleString = LocalizedString.Summary.Title
            let summary = "\(TitleString.prefix)\(data.cryptoCurrency.displayCode)\(TitleString.suffix)"
            summaryLabelContent = .init(
                text: summary,
                font: .mainMedium(14.0),
                color: .descriptionText,
                accessibility: .id(AccessibilityId.descriptionLabel)
            )
            cellArrangement = [
                .summary,
                .separator,
                .lineItem(.orderId),
                .lineItem(.date),
                .lineItem(.totalCost),
                .lineItem(.estimatedAmount),
                .lineItem(.buyingFee),
                .lineItem(.paymentMethod),
                .lineItem(.status),
                .separator,
                .disclaimer
            ]
        }
        
        let notice: String
        switch data.detailType.paymentMethod {
        case .card:
            notice = LocalizedString.cardNotice
        case .bankTransfer:
            notice = "\(LocalizedString.BankNotice.prefix) \(data.cryptoCurrency.displayCode) \(LocalizedString.BankNotice.suffix)"
        }
        noticeViewModel = NoticeViewModel(
            imageViewContent: .init(
                imageName: "disclaimer-icon",
                accessibility: .id(AccessibilityId.disclaimerImage),
                bundle: .platformUIKit
            ),
            labelContent: .init(
                text: notice,
                font: .mainMedium(12),
                color: .descriptionText,
                accessibility: .id(AccessibilityId.disclaimerLabel)
            ),
            verticalAlignment: .top
        )
        
        continueButtonViewModel = .primary(
            with: "\(LocalizedString.Summary.buttonPrefix)\(data.cryptoCurrency.displayCode)"
        )
        
        if interactor.isCancellable {
            cancelButtonViewModel = .cancel(with: LocalizationConstants.cancel)
        } else {
            cancelButtonViewModel = nil
        }
        
        let dateLineItemInteractor = DefaultLineItemCellInteractor()
        dateLineItemInteractor.title.stateRelay.accept(
            .loaded(next: .init(text: LocalizedString.LineItem.date))
        )
        dateLineItemCellPresenter = .init(interactor: dateLineItemInteractor)
        
        let orderIdLineItemInteractor = DefaultLineItemCellInteractor()
        orderIdLineItemInteractor.title.stateRelay.accept(
            .loaded(next: .init(text: LocalizedString.LineItem.orderId))
        )
        orderIdLineItemCellPresenter = .init(interactor: orderIdLineItemInteractor)
        
        let statusLineItemInteractor = DefaultLineItemCellInteractor()
        statusLineItemInteractor.title.stateRelay.accept(
            .loaded(next: .init(text: LocalizedString.LineItem.status))
        )
        statusLineItemInteractor.description.stateRelay.accept(
            .loaded(next: .init(text: LocalizedString.LineItem.pending))
        )
        statusLineItemCellPresenter = .init(interactor: statusLineItemInteractor)
        
        let totalCostLineItemInteractor = DefaultLineItemCellInteractor()
        totalCostLineItemInteractor.title.stateRelay.accept(
            .loaded(next: .init(text: LocalizedString.LineItem.totalCost))
        )
        totalCostLineItemInteractor.description.stateRelay.accept(
            .loaded(next: .init(text: data.fiatValue.toDisplayString()))
        )
        totalCostLineItemCellPresenter = .init(interactor: totalCostLineItemInteractor)

        let amountLineItemInteractor = DefaultLineItemCellInteractor()
        amountLineItemInteractor.title.stateRelay.accept(
            .loaded(next: .init(text: amountLineTitle))
        )
        amountLineItemCellPresenter = .init(interactor: amountLineItemInteractor)

        let feeLineItemInteractor = DefaultLineItemCellInteractor()
        feeLineItemInteractor.title.stateRelay.accept(
            .loaded(next: .init(text: LocalizedString.LineItem.buyingFee))
        )
        buyingFeeLineItemCellPresenter = .init(interactor: feeLineItemInteractor)

        let exchangeRateItemInteractor = DefaultLineItemCellInteractor()
        exchangeRateItemInteractor.title.stateRelay.accept(
            .loaded(next: .init(text: LocalizedString.LineItem.exchangeRate))
        )
        exchangeRateLineItemCellPresenter = .init(interactor: exchangeRateItemInteractor)

        let paymentMethodLineItemInteractor = DefaultLineItemCellInteractor()
        paymentMethodLineItemInteractor.title.stateRelay.accept(
            .loaded(next: .init(text: LocalizedString.LineItem.paymentMethod))
        )
        paymentMethodLineItemCellPresenter = .init(interactor: paymentMethodLineItemInteractor)
        
        continueButtonViewModel.tapRelay
            .show(loader: loadingViewPresenter, style: .circle)
            .flatMap(weak: self) { (self, _) in
                self.interactor.continue()
                    .mapToResult()
            }
            .hide(loader: loadingViewPresenter)
            .bind(weak: self) { (self, result) in
                switch result {
                case .success(let data):
                    self.stateService.confirmCheckout(
                        with: data
                    )
                case .failure:
                    self.alertPresenter.error()
                }
            }
            .disposed(by: disposeBag)
        
        continueButtonViewModel.tapRelay
            .map { _ in AnalyticsEvent.sbCheckoutConfirm }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
        
        cancelButtonViewModel?.tapRelay
            .bind(weak: self) { (self) in
                self.cancel()
            }
            .disposed(by: disposeBag)
        
        cancelButtonViewModel?.tapRelay
            .map { _ in AnalyticsEvent.sbCheckoutCancel }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
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
    
    func previous() {
        cancel()
    }
    
    // MARK: - Accessors
    
    private func setupDidSucceed(with data: CheckoutScreenInteractor.InteractionData) {
        let time = DateFormatter.elegantDateFormatter.string(from: data.time)
        dateLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: time))
        )
        buyingFeeLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: data.fee.toDisplayString()))
        )
        
        var amount = data.amount.toDisplayString(includeSymbol: true)
        if !interactor.checkoutData.hasCheckoutMade {
            amount = "~ \(amount)"
        }
        amountLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: amount))
        )
        exchangeRateLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: data.exchangeRate.toDisplayString(includeSymbol: true)))
        )
        orderIdLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: data.orderId))
        )
        
        let localizedPaymentMethod: String
        if let card = data.card {
            localizedPaymentMethod = "\(card.label) \(card.displaySuffix)"
        } else {
            localizedPaymentMethod = LocalizationConstants.SimpleBuy.Checkout.LineItem.bankTransfer
        }
        paymentMethodLineItemCellPresenter.interactor.description.stateRelay.accept(
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
