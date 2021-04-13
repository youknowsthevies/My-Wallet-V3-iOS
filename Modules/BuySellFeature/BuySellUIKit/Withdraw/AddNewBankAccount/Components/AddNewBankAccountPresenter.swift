//
//  AddNewBankAccountPresenter.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 08/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class AddNewBankAccountPagePresenter: DetailsScreenPresenterAPI, AddNewBankAccountPresentable {

    // MARK: - Types

    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.TransferDetails
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.TransferDetails

    // MARK: - Navigation Properties

    let reloadRelay: PublishRelay<Void> = .init()

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction
    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance {
        .custom(
            leading: .none,
            trailing: .close,
            barStyle: .darkContent(ignoresStatusBar: false, background: .white)
        )
    }

    // MARK: - Screen Properties

    private(set) var buttons: [ButtonViewModel] = []
    private(set) var cells: [DetailsScreen.CellType] = []

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let termsTapRelay = PublishRelay<TitledLink>()
    private let navigationCloseRelay = PublishRelay<Void>()

    // MARK: - Injected

    private let fiatCurrency: FiatCurrency
    private let isOriginDeposit: Bool
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    // MARK: - Setup

    init(isOriginDeposit: Bool,
         fiatCurrency: FiatCurrency,
         analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.isOriginDeposit = isOriginDeposit
        self.fiatCurrency = fiatCurrency
        self.analyticsRecorder = analyticsRecorder

        navigationBarTrailingButtonAction = .custom { [navigationCloseRelay] in
            navigationCloseRelay.accept(())
        }
    }

    func connect(action: Driver<AddNewBankAccountAction>) -> Driver<AddNewBankAccountEffects> {
        let details = action
            .flatMap { action -> Driver<AddNewBankAccountDetailsInteractionState> in
                switch action {
                case .details(let state):
                    return .just(state)
                }
            }

        details
            .drive(weak: self) { (self, state) in
                switch state {
                case .invalid(.valueCouldNotBeCalculated):
                    self.analyticsRecorder.record(
                        event: AnalyticsEvents.SimpleBuy.sbLinkBankLoadingError(
                            currencyCode: self.fiatCurrency.code
                        )
                    )
                case .value(let account):
                    self.setup(account: account)
                case .calculating, .invalid(.empty):
                    break
                }
            }
            .disposed(by: disposeBag)

        let closeTapped = navigationCloseRelay
            .map { _ in AddNewBankAccountEffects.close }
            .asDriverCatchError()

        let termsTapped = termsTapRelay
            .map(AddNewBankAccountEffects.termsTapped)
            .asDriverCatchError()

        return Driver.merge(closeTapped, termsTapped)
    }

    func viewDidLoad() {
        analyticsRecorder.record(
            event: AnalyticsEvents.SimpleBuy.sbLinkBankScreenShown(currencyCode: fiatCurrency.code)
        )
    }

    private func setup(account: BuySellKit.PaymentAccount) {
        let contentReducer = ContentReducer(
            account: account,
            isOriginDeposit: isOriginDeposit,
            analyticsRecorder: analyticsRecorder
        )

        // MARK: Nav Bar

        titleViewRelay.accept(.text(value: contentReducer.title))

        // MARK: Cells Setup

        contentReducer.lineItems
            .forEach { cells.append(.lineItem($0)) }
        cells.append(.separator)
        for noticeViewModel in contentReducer.noticeViewModels {
            cells.append(.notice(noticeViewModel))
        }

        if let termsTextViewModel = contentReducer.termsTextViewModel {
            termsTextViewModel.tap
                .bindAndCatch(to: termsTapRelay)
                .disposed(by: disposeBag)
            cells.append(.interactableTextCell(termsTextViewModel))
        }

        reloadRelay.accept(())
    }
}

// MARK: - Content Reducer

extension AddNewBankAccountPagePresenter {

    final class ContentReducer {

        let title: String
        let lineItems: [LineItemCellPresenting]
        let noticeViewModels: [NoticeViewModel]
        let termsTextViewModel: InteractableTextViewModel!

        init(account: BuySellKit.PaymentAccount,
             isOriginDeposit: Bool,
             analyticsRecorder: AnalyticsEventRecorderAPI) {

            typealias FundsString = LocalizedString.Funds

            if isOriginDeposit {
                title = "\(FundsString.Title.depositPrefix) \(account.currency)"
            } else {
                title = "\(FundsString.Title.addBankPrefix) \(account.currency) \(FundsString.Title.addBankSuffix) "
            }

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
