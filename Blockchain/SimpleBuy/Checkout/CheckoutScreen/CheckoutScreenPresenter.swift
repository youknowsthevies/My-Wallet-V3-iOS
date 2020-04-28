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
import PlatformKit
import PlatformUIKit
import ToolKit

final class CheckoutScreenPresenter {

    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout
    private typealias AccessibilityId = Accessibility.Identifier.LineItem
        
    // MARK: - Navigation Bar Properties
    
    var trailingButton: Screen.Style.TrailingButton { .none }
    var leadingButton: Screen.Style.LeadingButton { .back }
    var titleView: Screen.Style.TitleView { .text(value: LocalizedString.title) }
    var barStyle: Screen.Style.Bar {
        .darkContent(ignoresStatusBar: false, background: .white)
    }
    
    /// Returns the ordered cell types
    let cellArrangement: [CheckoutCellType] = {
        [
            .summary,
            .separator,
            .lineItem(.date),
            .lineItem(.totalCost),
            .lineItem(.estimatedAmount),
            .lineItem(.buyingFee),
            .lineItem(.paymentMethod),
            .separator,
            .disclaimer
        ]
    }()
    
    // MARK: - View Models / Presenters
    
    let summaryLabelContent: LabelContent
    let noticeViewModel: NoticeViewModel
    let buyButtonViewModel: ButtonViewModel
    let cancelButtonViewModel: ButtonViewModel
    
    // MARK: - Cell Presenters

    let dateLineItemCellPresenter: DefaultLineItemCellPresenter
    let totalCostLineItemCellPresenter: DefaultLineItemCellPresenter
    let estimatedLineItemCellPresenter: DefaultLineItemCellPresenter
    let buyingFeeLineItemCellPresenter: DefaultLineItemCellPresenter
    let paymentMethodLineItemCellPresenter: DefaultLineItemCellPresenter

    // MARK: - Injected
    
    private let analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording
    private let alertPresenter: AlertViewPresenter
    private let loadingViewPresenter: LoadingViewPresenting
    
    private let interactor: CheckoutScreenInteractor
    private unowned let stateService: SimpleBuyConfirmCheckoutServiceAPI

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
        
        let notice = "\(LocalizedString.Notice.prefix) \(data.cryptoCurrency.displayCode) \(LocalizedString.Notice.suffix)"
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
        
        typealias TitleString = LocalizedString.Summary.Title
        let summary = "\(TitleString.prefix)\(data.cryptoCurrency.displayCode)\(TitleString.suffix)"
        summaryLabelContent = .init(
            text: summary,
            font: .mainMedium(14.0),
            color: .descriptionText,
            accessibility: .id(AccessibilityId.descriptionLabel)
        )
        
        buyButtonViewModel = .primary(
            with: "\(LocalizedString.Summary.buttonPrefix)\(data.cryptoCurrency.displayCode)"
        )
        cancelButtonViewModel = .cancel(with: LocalizationConstants.cancel)
        
        let dateLineItemInteractor = DefaultLineItemCellInteractor()
        dateLineItemInteractor.title.stateRelay.accept(
            .loaded(next: .init(text: LocalizedString.LineItem.date))
        )
        dateLineItemCellPresenter = .init(interactor: dateLineItemInteractor)
        
        let totalCostLineItemInteractor = DefaultLineItemCellInteractor()
        totalCostLineItemInteractor.title.stateRelay.accept(
            .loaded(next: .init(text: LocalizedString.LineItem.totalCost))
        )
        totalCostLineItemInteractor.description.stateRelay.accept(
            .loaded(next: .init(text: data.fiatValue.toDisplayString()))
        )
        totalCostLineItemCellPresenter = .init(interactor: totalCostLineItemInteractor)

        let estimatedLineItemInteractor = DefaultLineItemCellInteractor()
        estimatedLineItemInteractor.title.stateRelay.accept(
            .loaded(next: .init(text: LocalizedString.LineItem.estimatedAmount))
        )
        estimatedLineItemCellPresenter = .init(interactor: estimatedLineItemInteractor)

        let feeLineItemInteractor = DefaultLineItemCellInteractor()
        feeLineItemInteractor.title.stateRelay.accept(
            .loaded(next: .init(text: LocalizedString.LineItem.buyingFee))
        )
        buyingFeeLineItemCellPresenter = .init(interactor: feeLineItemInteractor)

        let paymentMethodLineItemInteractor = DefaultLineItemCellInteractor()
        paymentMethodLineItemInteractor.title.stateRelay.accept(
            .loaded(next: .init(text: LocalizedString.LineItem.paymentMethod))
        )
        
        paymentMethodLineItemInteractor.description.stateRelay.accept(
            .loaded(next: .init(text: interactor.checkoutData.localizedPaymentMethod))
        )
        paymentMethodLineItemCellPresenter = .init(interactor: paymentMethodLineItemInteractor)
        
        buyButtonViewModel.tapRelay
            .show(loader: loadingViewPresenter, style: .circle)
            .flatMap(weak: self) { (self, _) in
                self.interactor.confirm()
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
        
        buyButtonViewModel.tapRelay
            .map { _ in AnalyticsEvent.sbCheckoutConfirm }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
        
        cancelButtonViewModel.tapRelay
            .bind(weak: self) { (self) in
                self.cancel()
            }
            .disposed(by: disposeBag)
        
        cancelButtonViewModel.tapRelay
            .map { _ in AnalyticsEvent.sbCheckoutCancel }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
    }
    
    /// Should get called once, when the view has finished loading
    func viewDidLoad() {
        interactor.setup()
            .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
            .subscribe(
                onSuccess: { [weak self] quote in
                    self?.setupDidSucceed(with: quote)
                },
                onError: { [weak self] _ in
                    self?.setupDidFail()
                }
            )
            .disposed(by: disposeBag)
        
        analyticsRecorder.record(event: AnalyticsEvent.sbCheckoutShown)
    }
    
    private func cancel() {
        interactor.cancel()
            .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
            .subscribe(
                onCompleted: { [weak self] in
                    guard let self = self else { return }
                    self.analyticsRecorder.record(event: AnalyticsEvent.sbCheckoutCancelGoBack)
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
    
    private func setupDidSucceed(with quote: SimpleBuyQuote) {
        let time = DateFormatter.elegantDateFormatter.string(from: quote.time)
        dateLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: time))
        )
        buyingFeeLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: quote.fee.toDisplayString()))
        )
        let estimatedAmount = "~ \(quote.estimatedAmount.toDisplayString(includeSymbol: true))"
        estimatedLineItemCellPresenter.interactor.description.stateRelay.accept(
            .loaded(next: .init(text: estimatedAmount))
        )
    }
    
    /// Is called as the interaction setup fails
    private func setupDidFail() {
        alertPresenter.error { [weak stateService] in
            stateService?.previousRelay.accept(())
        }
    }
}

fileprivate extension SimpleBuyCheckoutData {
    var localizedPaymentMethod: String {
        var localizedPaymentMethod = ""
        switch detailType {
        case .candidate(let details):
            switch details.paymentMethod {
            case .card(let card):
                localizedPaymentMethod = "\(card.label) \(card.displaySuffix)"
            case .suggested(let method):
                switch method.type {
                case .bankTransfer:
                    localizedPaymentMethod = LocalizationConstants.SimpleBuy.Checkout.LineItem.bankTransfer
                case .card:
                    break
                }
            }
        case .order:
            break
        }
        return localizedPaymentMethod
    }
}
