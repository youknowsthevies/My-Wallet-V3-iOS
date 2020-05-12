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
    private let webViewRouter: WebViewRouterAPI
    private let stateService: SimpleBuyStateServiceAPI
    private let interactor: SimpleBuyTransferDetailScreenInteractor

    // MARK: - Setup

    init(webViewRouter: WebViewRouterAPI,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared,
         interactor: SimpleBuyTransferDetailScreenInteractor,
         stateService: SimpleBuyStateServiceAPI) {
        self.analyticsRecorder = analyticsRecorder
        self.webViewRouter = webViewRouter
        self.interactor = interactor
        self.stateService = stateService

        contentReducer = ContentReducer(
            data: interactor.checkoutData
        )

        // MARK: Continue Button Setup

        let continueButtonViewModel = ButtonViewModel.primary(with: LocalizedString.Button.ok)
        continueButtonViewModel.tapRelay
            .bind(weak: self) { (self) in
                self.stateService.nextRelay.accept(())
            }
            .disposed(by: disposeBag)
        continueButtonViewModel
            .tapRelay
            .bind(weak: self) { (self) in
                self.analyticsRecorder.record(event: AnalyticsEvent.sbBankDetailsFinished)
            }
            .disposed(by: disposeBag)
        buttons.append(continueButtonViewModel)

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

        cells.append(.staticLabel(summary))
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
    }

    // MARK: - View Life Cycle

    func viewDidLoad() {
        let currencyCode = interactor.checkoutData.fiatValue.currencyCode
        analyticsRecorder.record(event: AnalyticsEvent.sbBankDetailsShown(currencyCode: currencyCode))
    }
}

// MARK: - Content Reducer

extension SimpleBuyTransferDetailScreenPresenter {

    final class ContentReducer {

        let title: String
        let summary: String
        let lineItems: [LineItemCellPresenting]
        let termsTextViewModel: InteractableTextViewModel!

        init(data: SimpleBuyCheckoutData) {
            typealias SummaryString = LocalizedString.Summary
            typealias TitleString = LocalizedString.Title
            let currency = data.fiatValue.currency
            let currencyString = "\(currency.name) (\(currency.symbol))"

            title = TitleString.checkout
            switch data.fiatValue.currency {
            case .USD, .GBP:
                summary = "\(SummaryString.GbpAndUsd.prefix) \(currencyString) \(SummaryString.GbpAndUsd.suffix)"
            default:
                summary = "\(SummaryString.AnyFiat.prefix) \(currencyString) \(SummaryString.AnyFiat.suffix)"
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
