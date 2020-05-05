//
//  CheckoutDetailScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class SimpleBuyTransferDetailScreenPresenter: DetailsScreenPresenterAPI {

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

    // MARK: - Screen Properties

    private(set) var buttons: [ButtonViewModel] = []

    private(set) var cells: [DetailsScreen.CellType] = []

    // MARK: - Navigation Properties

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default
    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance {
        .custom(leading: .none, trailing: .none, barStyle: .darkContent(ignoresStatusBar: false, background: .white))
    }

    var titleView: Screen.Style.TitleView {
        .text(value: contentReducer.title)
    }

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let contentReducer: ContentReducer

    // MARK: - Injected

    private let analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording
    private let presentationType: PresentationType
    private let webViewRouter: WebViewRouterAPI
    private let stateService: SimpleBuyStateServiceAPI
    private let interactor: SimpleBuyTransferDetailScreenInteractor

    // MARK: - Setup

    init(presentationType: PresentationType,
         webViewRouter: WebViewRouterAPI,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared,
         interactor: SimpleBuyTransferDetailScreenInteractor,
         stateService: SimpleBuyStateServiceAPI) {
        self.analyticsRecorder = analyticsRecorder
        self.presentationType = presentationType
        self.webViewRouter = webViewRouter
        self.interactor = interactor
        self.stateService = stateService

        contentReducer = ContentReducer(
            data: interactor.checkoutData,
            presentationType: presentationType
        )

        // MARK: Cells Setup

        let summary = LabelContent(
            text: contentReducer.summary,
            font: .main(.medium, 14.0),
            color: .descriptionText,
            accessibility: .id(AccessibilityId.descriptionLabel)
        )

        let notice = NoticeViewModel(
            imageViewContent: .init(
                imageName: "disclaimer-icon",
                accessibility: .id(AccessibilityId.disclaimerImage),
                bundle: .platformUIKit
            ),
            labelContent: .init(
                text: LocalizedString.disclaimer,
                font: .main(.medium, 12),
                color: .descriptionText,
                accessibility: .id(AccessibilityId.disclaimerLabel)
            ),
            verticalAlignment: .top
        )

        let totalCost = CheckoutCellType.LineItemType
            .totalCost(interactor.checkoutData.fiatValue.toDisplayString())
            .presenter()

        cells.append(.label(summary))
        cells.append(.separator)
        contentReducer
            .lineItems
            .forEach { cells.append(.lineItem($0)) }
        cells.append(.lineItem(totalCost))
        cells.append(.separator)
        cells.append(.notice(notice))
        if let termsTextViewModel = contentReducer.termsTextViewModel {
            termsTextViewModel.tap
                .bind(to: webViewRouter.launchRelay)
                .disposed(by: disposeBag)
            cells.append(.interactableTextCell(termsTextViewModel))
        }

        // MARK: Continue Button Setup

        let continueButtonViewModel = ButtonViewModel.primary(with: LocalizedString.Button.ok)
        continueButtonViewModel.tapRelay
            .bind(weak: self) { (self) in
                self.stateService.nextRelay.accept(())
            }
            .disposed(by: disposeBag)
        continueButtonViewModel.tapRelay
            .bind(weak: self) { (self) in
                if self.presentationType == .checkoutSummary {
                    self.analyticsRecorder.record(event: AnalyticsEvent.sbBankDetailsFinished)
                }
            }
            .disposed(by: disposeBag)
        buttons.append(continueButtonViewModel)

        // MARK: Cancel Button Setup

        switch presentationType {
        case .pendingOrder:
            let cancelButtonViewModel = ButtonViewModel.cancel(with: LocalizedString.Button.cancel)
            cancelButtonViewModel.tapRelay
                .bind(weak: self) { (self) in
                    self.analyticsRecorder.record(event: AnalyticsEvent.sbPendingModalCancelClick)
                    self.stateService.cancelTransfer(with: self.interactor.checkoutData)
            }
            .disposed(by: disposeBag)
            buttons.append(cancelButtonViewModel)
        case .checkoutSummary:
            break
        }
    }

    // MARK: - View Life Cycle

    func viewDidLoad() {
        let currencyCode = interactor.checkoutData.fiatValue.currencyCode
        switch presentationType {
        case .checkoutSummary:
            analyticsRecorder.record(event: AnalyticsEvent.sbBankDetailsShown(currencyCode: currencyCode))
        case .pendingOrder:
            analyticsRecorder.record(event: AnalyticsEvent.sbPendingModalShown(currencyCode: currencyCode))
        }
    }
}

// MARK: - Content Reducer

extension SimpleBuyTransferDetailScreenPresenter {

    final class ContentReducer {

        let title: String
        let summary: String
        let lineItems: [LineItemCellPresenting]
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
                title = "\(TitleString.pendingOrderPrefix) \(data.cryptoCurrency.displayCode) \(TitleString.pendingOrderSuffix)"
                summary = "\(SummaryString.PendingOrder.prefix) \(currencyString) \(SummaryString.PendingOrder.middle) \(data.cryptoCurrency.displayCode) \(SummaryString.PendingOrder.suffix)"
            }

            let account = data.paymentAccount!
            lineItems = account.fields
                .map { CheckoutCellType.LineItemType.paymentAccountField($0) }
                .map { $0.presenter() }

            switch currency {
            case .GBP:
                typealias LinkString = LocalizedString.TermsLink.GBP
                let font = UIFont.main(.medium, 12)
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
    }
}
