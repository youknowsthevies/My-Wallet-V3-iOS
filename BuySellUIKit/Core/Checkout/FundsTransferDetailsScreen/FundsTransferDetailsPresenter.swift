//
//  FundsTransferDetailsPresenter.swift
//  BuySellUIKit
//
//  Created by Daniel on 23/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import Localization
import ToolKit
import PlatformKit
import PlatformUIKit
import BuySellKit

final class FundsTransferDetailScreenPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.TransferDetails
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.TransferDetails

    // MARK: - Screen Properties

    let reloadRelay: PublishRelay<Void> = .init()

    private(set) var buttons: [ButtonViewModel] = []

    private(set) var cells: [DetailsScreen.CellType] = []

    // MARK: - Navigation Properties

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction
    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance {
        .custom(
            leading: .none,
            trailing: .close,
            barStyle: .darkContent(ignoresStatusBar: false, background: .white)
        )
    }

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let webViewRouter: WebViewRouterAPI
    private let stateService: StateServiceAPI
    private let interactor: FundsTransferDetailsInteractorAPI
    
    // MARK: - Setup

    init(webViewRouter: WebViewRouterAPI,
         analyticsRecorder: AnalyticsEventRecorderAPI,
         interactor: FundsTransferDetailsInteractorAPI,
         stateService: StateServiceAPI) {
        self.analyticsRecorder = analyticsRecorder
        self.webViewRouter = webViewRouter
        self.interactor = interactor
        self.stateService = stateService
        
        navigationBarTrailingButtonAction = .custom {
            stateService.previousRelay.accept(())
        }
    }
    
    func viewDidLoad() {
        analyticsRecorder.record(
            event: AnalyticsEvents.SimpleBuy.sbLinkBankScreenShown(currencyCode: interactor.fiatCurrency.code)
        )
        
        interactor.state
            .bindAndCatch(weak: self) { (self, state) in
                switch state {
                case .invalid(.valueCouldNotBeCalculated):
                    self.analyticsRecorder.record(
                        event: AnalyticsEvents.SimpleBuy.sbLinkBankLoadingError(
                            currencyCode: self.interactor.fiatCurrency.code
                        )
                    )
                case .value(let account):
                    self.setup(account: account)
                case .calculating, .invalid(.empty):
                    break
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func setup(account: PaymentAccount) {
        let contentReducer = ContentReducer(
            account: account,
            analyticsRecorder: analyticsRecorder
        )

        // MARK: Nav Bar

        titleViewRelay.accept(.text(value: contentReducer.title))

        // MARK: Continue Button Setup

        let continueButtonViewModel = ButtonViewModel.primary(with: LocalizedString.Button.ok)
        continueButtonViewModel.tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.stateService.previousRelay.accept(())
            }
            .disposed(by: disposeBag)
        buttons.append(continueButtonViewModel)

        // MARK: Cells Setup

        contentReducer.lineItems
            .forEach { cells.append(.lineItem($0)) }
        cells.append(.separator)
        for noticeViewModel in contentReducer.noticeViewModels {
            cells.append(.notice(noticeViewModel))
        }

        if let termsTextViewModel = contentReducer.termsTextViewModel {
            termsTextViewModel.tap
                .bind(to: webViewRouter.launchRelay)
                .disposed(by: disposeBag)
            cells.append(.interactableTextCell(termsTextViewModel))
        }
        
        reloadRelay.accept(())
    }
}

// MARK: - Content Reducer

extension FundsTransferDetailScreenPresenter {

    final class ContentReducer {

        let title: String
        let lineItems: [LineItemCellPresenting]
        let noticeViewModels: [NoticeViewModel]
        let termsTextViewModel: InteractableTextViewModel!

        init(account: PaymentAccount,
             analyticsRecorder: AnalyticsEventRecorderAPI) {
        
            typealias FundsString = LocalizedString.Funds
            
            title = "\(FundsString.Title.addBankPrefix) \(account.currency) \(FundsString.Title.addBankSuffix) "
            lineItems = account.fields.transferDetailsCellsPresenting(analyticsRecorder: analyticsRecorder)

            let font = UIFont.main(.medium, 12)
            
            let processingTimeNoticeDescription: String

            switch account.currency {
            case .GBP:
                processingTimeNoticeDescription = FundsString.Notice.ProcessingTime.Description.GBP
                termsTextViewModel = InteractableTextViewModel(
                    inputs: [
                        .text(string: FundsString.Notice.recipientNameGBPPrefix),
                        .url(string: " \(FundsString.Notice.termsAndConditions) ", url: TermsUrlLink.gbp),
                        .text(string: FundsString.Notice.recipientNameGBPSuffix)
                    ],
                    textStyle: .init(color: .descriptionText, font: font),
                    linkStyle: .init(color: .linkableText, font: font)
                )
            case .EUR:
                processingTimeNoticeDescription = FundsString.Notice.ProcessingTime.Description.EUR
                termsTextViewModel = InteractableTextViewModel(
                    inputs: [.text(string: FundsString.Notice.recipientNameEUR)],
                    textStyle: .init(color: .descriptionText, font: font),
                    linkStyle: .init(color: .linkableText, font: font)
                )
            default:
                processingTimeNoticeDescription = ""
                termsTextViewModel = nil
            }
            
            noticeViewModels = [
                    (
                        title: FundsString.Notice.BankTransferOnly.title,
                        description: FundsString.Notice.BankTransferOnly.description,
                        imageName: "icon-bank"
                    ),
                    (
                        title: FundsString.Notice.ProcessingTime.title,
                        description: processingTimeNoticeDescription,
                        imageName: "clock-icon"
                    )
                ]
                .map {
                    NoticeViewModel(
                        imageViewContent: ImageViewContent(
                            imageName: $0.imageName,
                            renderingMode: .template(.titleText),
                            bundle: .platformUIKit
                        ),
                        labelContents: [
                            LabelContent(
                                text: $0.title,
                                font: .main(.semibold, 12),
                                color: .titleText
                            ),
                            LabelContent(
                                text: $0.description,
                                font: .main(.medium, 12),
                                color: .descriptionText
                            )
                        ],
                        verticalAlignment: .top
                    )
                }
        }
    }
}

private extension Array where Element == PaymentAccountProperty.Field {
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.TransferDetails

    func transferDetailsCellsPresenting(analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording) -> [LineItemCellPresenting] {

        func isCopyable(field: TransactionalLineItem) -> Bool {
            switch field {
            case .paymentAccountField(.accountNumber),
                 .paymentAccountField(.iban),
                 .paymentAccountField(.bankCode),
                 .paymentAccountField(.sortCode):
                return true
            default:
                return false
            }
        }

        func analyticsEvent(field: TransactionalLineItem) -> AnalyticsEvents.SimpleBuy? {
            switch field {
            case .paymentAccountField:
                return .sbLinkBankDetailsCopied
            default:
                return nil
            }
        }
        
        return map { TransactionalLineItem.paymentAccountField($0) }
            .map { field in
                if isCopyable(field: field) {
                    return field.defaultCopyablePresenter(
                        analyticsEvent: analyticsEvent(field: field),
                        analyticsRecorder: analyticsRecorder,
                        accessibilityIdPrefix: AccessibilityId.lineItemPrefix
                    )
                } else {
                    return field.defaultPresenter(accessibilityIdPrefix: AccessibilityId.lineItemPrefix)
                }
            }
    }
}
