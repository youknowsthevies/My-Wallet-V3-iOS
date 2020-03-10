//
//  CheckoutDetailScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import RxRelay
import ToolKit
import PlatformKit
import PlatformUIKit

final class SimpleBuyTransferDetailScreenPresenter {
    
    // MARK: - Types
    
    /// The presentation type of the simple buy screen
    enum PresentationType {
        
        /// A presentation type for pending order. In case the user
        /// has an order which is currently at a pending-deposit state.
        case pendingOrder
        
        /// A presentation type for checkout summary. Once the user
        /// did a checkout by completing a simple buy flow.
        case checkoutSummary
    }
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.TransferDetails
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.TransferDetails

    // MARK: - Navigation Properties
    
    let trailingButton = Screen.Style.TrailingButton.none
    let leadingButton = Screen.Style.LeadingButton.none
    var titleView: Screen.Style.TitleView {
        .text(value: contentReducer.title)
    }
    var barStyle: Screen.Style.Bar {
        .lightContent(ignoresStatusBar: false, background: .navigationBarBackground)
    }
    
    /// The dashboard action
    var action: Signal<SimpleBuyCheckoutAction> {
        actionRelay.asSignal()
    }
    
    var cellArrangement: [CheckoutCellType] {
        let prefix: [CheckoutCellType] = [.summary, .separator]
        let mid = contentReducer.lineItems.map { CheckoutCellType.lineItem($0) }
        var suffix: [CheckoutCellType] = [.lineItem(.totalCost), .separator, .disclaimer]
        if contentReducer.termsTextViewModel != nil {
            suffix += [.termsAndConditions]
        }
        return prefix + mid + suffix
    }
    
    var termsViewModel: InteractableTextViewModel! {
        contentReducer.termsTextViewModel
    }
    
    let noticeViewModel: NoticeViewModel
    
    let cancelButtonViewModel: ButtonViewModel!
    let continueButtonViewModel: ButtonViewModel
    
    // MARK: - Cell Presenters
    
    private(set) var presentersByCellType: [CheckoutCellType.LineItemType: LineItemCellPresenting] = [:]
    let summaryLabelContent: LabelContent

    // MARK: - Private Properties
    
    private let actionRelay = PublishRelay<SimpleBuyCheckoutAction>()
    private let disposeBag = DisposeBag()
    private let contentReducer: ContentReducer
    
    // MARK: - Injected
    
    private let analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording
    private let presentationType: PresentationType
    private let webViewRouter: WebViewRouterAPI
    private let loadingViewPresenter: LoadingViewPresenting
    private let alertPresenter: AlertViewPresenter
    private let stateService: SimpleBuyStateServiceAPI
    private let interactor: SimpleBuyTransferDetailScreenInteractor
    
    // MARK: - Setup
    
    init(presentationType: PresentationType,
         alertPresenter: AlertViewPresenter = .shared,
         webViewRouter: WebViewRouterAPI,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared,
         interactor: SimpleBuyTransferDetailScreenInteractor,
         stateService: SimpleBuyStateServiceAPI) {
        self.analyticsRecorder = analyticsRecorder
        self.presentationType = presentationType
        self.webViewRouter = webViewRouter
        self.loadingViewPresenter = loadingViewPresenter
        self.alertPresenter = alertPresenter
        self.interactor = interactor
        self.stateService = stateService
        contentReducer = ContentReducer(
            data: interactor.checkoutData,
            presentationType: presentationType
        )

        summaryLabelContent = .init(
            text: contentReducer.summary,
            font: .mainMedium(14.0),
            color: .descriptionText,
            accessibility: .id(AccessibilityId.descriptionLabel)
        )
        
        noticeViewModel = NoticeViewModel(
            image: "disclaimer-icon",
            labelContent: .init(
                text: LocalizedString.disclaimer,
                font: .mainMedium(12),
                color: .descriptionText,
                accessibility: .id(AccessibilityId.disclaimerLabel)
            )
        )
        
        switch presentationType {
        case .pendingOrder:
            cancelButtonViewModel = .cancel(with: LocalizedString.Button.cancel)
        case .checkoutSummary:
            cancelButtonViewModel = nil
        }
        
        continueButtonViewModel = .primary(with: LocalizedString.Button.ok)
        
        let pastboardPresenters = contentReducer.lineItems
            .filter { $0.isCopyable }
            .map { item -> [CheckoutCellType.LineItemType: PasteboardingLineItemCellPresenter] in
                let presenter = PasteboardingLineItemCellPresenter(
                    input: .init(
                        title: item.title,
                        titleInteractionText: LocalizationConstants.SimpleBuy.Checkout.LineItem.Copyable.copied,
                        description: item.paymentAccountField?.content ?? "",
                        descriptionInteractionText: contentReducer.copyMessage(for: item),
                        analyticsEvent: item.analyticsEvent
                    )
                )
                return [item: presenter]
            }
            .reduce([:], +)
        
        presentersByCellType += pastboardPresenters
        presentersByCellType += contentReducer.lineItems
            .filter { !$0.isCopyable }
            .map { item in
                let interactor = DefaultLineItemCellInteractor(
                    title: .init(knownValue: item.title),
                    description: .init(knownValue: item.paymentAccountField?.content ?? "")
                )
                let presenter = DefaultLineItemCellPresenter(interactor: interactor)
                return [item: presenter]
            }
            .reduce([:], +)
        
        let amountCellType = CheckoutCellType.LineItemType.totalCost
        let amountInteractor = DefaultLineItemCellInteractor(
            title: .init(knownValue: amountCellType.title),
            description: .init(knownValue: interactor.checkoutData.fiatValue.toDisplayString())
        )
        let amountPresenter = DefaultLineItemCellPresenter(interactor: amountInteractor)
        presentersByCellType += [amountCellType: amountPresenter]
                  
        continueButtonViewModel.tapRelay
            .bind(weak: self) { (self) in
                if presentationType == .checkoutSummary {
                    analyticsRecorder.record(event: AnalyticsEvent.sbBankDetailsFinished)
                }
                stateService.nextRelay.accept(())
            }
            .disposed(by: disposeBag)
        
        setupCancellationBindingIfNeeded()
        setupTermsViewModelIfNeeded()
    }
    
    // MARK: - Setup Cancellation
    
    private func setupTermsViewModelIfNeeded() {
        termsViewModel?.tap
            .bind(to: webViewRouter.launchRelay)
            .disposed(by: disposeBag)
    }
    
    private func setupCancellationBindingIfNeeded() {
        guard let cancelButtonViewModel = cancelButtonViewModel else { return }
        cancelButtonViewModel.tapRelay
            .bind(weak: self) { (self) in
                self.analyticsRecorder.record(event: AnalyticsEvent.sbPendingModalCancelClick)
                self.stateService.cancelTransfer(with: self.interactor.checkoutData)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Analytics
    
    func viewDidLoad() {
        let currencyCode = interactor.checkoutData.fiatValue.currencyCode
        switch presentationType {
        case .checkoutSummary:
            analyticsRecorder.record(event: AnalyticsEvent.sbBankDetailsShown(currencyCode: currencyCode))
        case .pendingOrder:
            analyticsRecorder.record(event: AnalyticsEvent.sbPendingModalShown(currencyCode: currencyCode))
        }
    }
    
    // MARK: - Navigation
    
    func navigationBarLeadingButtonTapped() {
        stateService.previousRelay.accept(())
    }
    
    /// TODO: Look for a more elegant way to communicate the tap
    func didSelectItem(with index: Int) {
        let cellType = cellArrangement[index]
        guard case .lineItem(let lineItem) = cellType else {
            return
        }
        guard let presenter = presentersByCellType[lineItem] as? PasteboardLineItemPresenting else {
            return
        }
        presenter.tapRelay.accept(())
    }
    
    private func cancellationDidFail() {
         typealias AlertString = LocalizationConstants.SimpleBuy.ErrorAlert
         alertPresenter.standardNotify(
             message: AlertString.message,
             title: AlertString.title,
             actions: [UIAlertAction(title: AlertString.button, style: .default)]
         )
     }
}

// MARK: - Content Reducer

extension SimpleBuyTransferDetailScreenPresenter {
    
    final class ContentReducer {
        
        let title: String
        let summary: String
        let lineItems: [CheckoutCellType.LineItemType]
        let termsTextViewModel: InteractableTextViewModel!

        init(data: SimpleBuyCheckoutData, presentationType: PresentationType) {
            typealias SummaryString = LocalizedString.Summary
            typealias TitleString = LocalizedString.Title
            let currency = data.fiatValue.currency
            let currencyString = "\(currency.name) (\(currency.symbol))"
            switch presentationType {
            case .checkoutSummary:
                title = TitleString.checkout
                switch data.fiatValue.currency {
                case .USD, .GBP:
                    summary = "\(SummaryString.GbpAndUsd.prefix) \(currencyString) \(SummaryString.GbpAndUsd.suffix)"
                default:
                    summary = "\(SummaryString.AnyFiat.prefix) \(currencyString) \(SummaryString.AnyFiat.suffix)"
                }
            case .pendingOrder:
                title = String(
                    format: TitleString.pendingOrder,
                    data.cryptoCurrency.code
                )
                summary = String(
                    format: SummaryString.pendingOrder,
                    currencyString,
                    data.cryptoCurrency.code
                )
            }

            let account = data.paymentAccount!
            lineItems = account.fields.map { .paymentAccountField($0) }
            
            switch currency {
            case .GBP:
                typealias LinkString = LocalizedString.TermsLink.GBP
                let font = UIFont.mainMedium(12)
                termsTextViewModel = InteractableTextViewModel(
                    inputs: [
                        .text(string: LinkString.prefix),
                        .url(string: LinkString.link, url: Constants.Url.simpleBuyGBPTerms),
                        .text(string: LinkString.suffix)
                    ],
                    textStyle: .init(color: .descriptionText, font: font),
                    linkStyle: .init(color: .linkableText, font: font)
                )
            default:
                termsTextViewModel = nil
            }
        }
        
        func copyMessage(for field: CheckoutCellType.LineItemType) -> String {
            typealias CopyString = LocalizationConstants.SimpleBuy.Checkout.LineItem.Copyable
            switch field {
            case .paymentAccountField(.iban):
                return "\(CopyString.iban) \(CopyString.copyMessageSuffix)"
            case .paymentAccountField(.bankCode):
                return "\(CopyString.bankCode) \(CopyString.copyMessageSuffix)"
            default:
                return CopyString.defaultCopyMessage
            }
        }
    }
}
