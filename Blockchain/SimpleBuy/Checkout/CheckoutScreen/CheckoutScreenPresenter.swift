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
    var leadingButton: Screen.Style.LeadingButton { .close }
    var titleView: Screen.Style.TitleView { .text(value: LocalizedString.title) }
    var barStyle: Screen.Style.Bar {
        return .lightContent(ignoresStatusBar: false, background: .navigationBarBackground)
    }
    
    /// Returns the ordered cell types
    let cellArrangement: [CheckoutCellType] = {
        return [.summary,
                .separator,
                .lineItem(.date),
                .lineItem(.totalCost),
                .lineItem(.estimatedAmount),
                .lineItem(.buyingFee),
                .separator,
                .disclaimer]
    }()
    
    /// MARK: - View Models / Presenters
    
    let summaryLabelContent: LabelContent
    let noticeViewModel: NoticeViewModel
    let buyButtonViewModel: ButtonViewModel
    let cancelButtonViewModel: ButtonViewModel
    
    // MARK: - Cell Presenters

    let dateLineItemCellPresenter: DefaultLineItemCellPresenter
    let totalCostLineItemCellPresenter: DefaultLineItemCellPresenter
    let estimatedLineItemCellPresenter: DefaultLineItemCellPresenter
    let buyingFeeLineItemCellPresenter: DefaultLineItemCellPresenter

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
        
        let notice = String(
            format: LocalizedString.notice,
            data.cryptoCurrency.displayCode
        )
        noticeViewModel = NoticeViewModel(
            image: "disclaimer-icon",
            labelContent: .init(
                text: notice,
                font: .mainMedium(12),
                color: .descriptionText,
                accessibility: .id(AccessibilityId.disclaimerLabel)
            )
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

        buyButtonViewModel.tapRelay
            .show(loader: loadingViewPresenter, style: .circle)
            .flatMap(weak: self) { (self, _) in
                self.interactor.buy()
            }
            .mapToResult()
            .hide(loader: loadingViewPresenter)
            .bind(weak: self) { (self, result) in
                switch result {
                case .success:
                    self.stateService.confirmCheckout(
                        with: self.interactor.checkoutData
                    )
                case .failure:
                    self.buyDidFail()
                }
            }
            .disposed(by: disposeBag)
        
        buyButtonViewModel.tapRelay
            .map { _ in AnalyticsEvent.sbCheckoutConfirm }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
        
        cancelButtonViewModel.tapRelay
            .bind(to: stateService.previousRelay)
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
    
    // MARK: - Navigation
    
    func navigationBarLeadingButtonTapped() {
        analyticsRecorder.record(event: AnalyticsEvent.sbCheckoutCancelGoBack)
        stateService.previousRelay.accept(())
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
        typealias AlertString = LocalizationConstants.SimpleBuy.ErrorAlert
        let action = UIAlertAction(
            title: AlertString.button,
            style: .default) { [weak stateService] _ in
                stateService?.previousRelay.accept(())
            }
        alertPresenter.standardNotify(
            message: AlertString.message,
            title: AlertString.title,
            actions: [action]
        )
    }
    
    private func buyDidFail() {
        typealias AlertString = LocalizationConstants.SimpleBuy.ErrorAlert
        alertPresenter.standardNotify(
            message: AlertString.message,
            title: AlertString.title,
            actions: [UIAlertAction(title: AlertString.button, style: .default)]
        )
    }
}
