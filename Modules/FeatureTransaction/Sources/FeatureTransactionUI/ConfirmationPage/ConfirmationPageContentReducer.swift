// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

protocol ConfirmationPageContentReducing {
    /// The title of the checkout screen
    var title: String { get }
    /// The `Cells` on the `ConfirmationPage`
    var cells: [DetailsScreen.CellType] { get }
    var continueButtonViewModel: ButtonViewModel { get }
    var cancelButtonViewModel: ButtonViewModel { get }
}

final class ConfirmationPageContentReducer: ConfirmationPageContentReducing {

    // MARK: - Types

    typealias ConfirmationModel = TransactionConfirmation.Model

    // MARK: - Private Types

    private typealias LocalizedString = LocalizationConstants.Transaction

    // MARK: - CheckoutScreenContentReducing

    let title: String
    var cells: [DetailsScreen.CellType]
    let continueButtonViewModel: ButtonViewModel
    let cancelButtonViewModel: ButtonViewModel

    let termsCheckboxViewModel = CheckboxViewModel()
    let transferCheckboxViewModel = CheckboxViewModel()

    let messageRecorder: MessageRecording
    let transferAgreementUpdated = PublishRelay<Bool>()
    let termsUpdated = PublishRelay<Bool>()
    let memoUpdated = PublishRelay<(String, TransactionConfirmation.Model.Memo)>()
    private let memoModel: TextFieldViewModel
    private var disposeBag = DisposeBag()

    // MARK: - Private Properties

    init(messageRecorder: MessageRecording = resolve()) {
        self.messageRecorder = messageRecorder
        title = LocalizedString.Confirmation.confirm
        cancelButtonViewModel = .cancel(with: LocalizedString.Confirmation.cancel)
        continueButtonViewModel = .primary(with: "")
        cells = []
        memoModel = TextFieldViewModel(
            with: .memo,
            validator: TextValidationFactory.General.alwaysValid,
            messageRecorder: messageRecorder
        )

        termsCheckboxViewModel
            .apply(
                text: LocalizedString.Transfer.termsOfServiceDisclaimer
            )
    }

    func setup(for state: TransactionState) {
        disposeBag = DisposeBag()
        continueButtonViewModel.textRelay.accept(Self.confirmCtaText(state: state))
        let amount = state.amount.displayString
        let sourceLabel = state.source?.label ?? ""
        transferCheckboxViewModel.apply(
            text: String(
                format: LocalizedString.Transfer.transferAgreement,
                amount,
                sourceLabel
            )
        )

        guard let pendingTransaction = state.pendingTransaction else {
            cells = []
            return
        }

        let interactors: [DefaultLineItemCellPresenter] = pendingTransaction
            .confirmations
            .filter { confirmation -> Bool in
                !confirmation.isCustom
            }
            .compactMap(\.formatted)
            .map { data -> (title: LabelContentInteracting, subtitle: LabelContentInteracting) in
                (DefaultLabelContentInteractor(knownValue: data.0), DefaultLabelContentInteractor(knownValue: data.1))
            }
            .map { data in
                DefaultLineItemCellInteractor(title: data.title, description: data.subtitle)
            }
            .map { interactor in
                DefaultLineItemCellPresenter(
                    interactor: interactor,
                    accessibilityIdPrefix: interactor.title.stateRelay.value.value?.text ?? ""
                )
            }

        var bitpayItemIfNeeded: [DetailsScreen.CellType] = pendingTransaction
            .confirmations
            .filter(\.isBitPay)
            .compactMap(\.formatted)
            .map { data -> (title: LabelContentInteracting, subtitle: LabelContentInteracting) in
                (DefaultLabelContentInteractor(knownValue: data.0), DefaultLabelContentInteractor(knownValue: data.1))
            }
            .map { data in
                DefaultLineItemCellInteractor(title: data.title, description: data.subtitle)
            }
            .map { interactor -> DetailsScreen.CellType in
                let presenter = DefaultLineItemCellPresenter(
                    interactor: interactor,
                    accessibilityIdPrefix: interactor.title.stateRelay.value.value?.text ?? ""
                )
                setupBitPay(on: presenter)
                return .lineItem(presenter)
            }
        if !bitpayItemIfNeeded.isEmpty {
            bitpayItemIfNeeded.append(.separator)
        }

        let confirmationLineItems: [DetailsScreen.CellType] = interactors
            .reduce(into: [DetailsScreen.CellType]()) { result, lineItem in
                result.append(.lineItem(lineItem))
                result.append(.separator)
            }

        let errorModels: [DetailsScreen.CellType] = pendingTransaction.confirmations
            .filter(\.isErrorNotice)
            .compactMap(\.formatted)
            .map { (_: String, subtitle: String) -> DefaultLabelContentPresenter in
                DefaultLabelContentPresenter(
                    knownValue: subtitle,
                    descriptors: .init(
                        fontWeight: .semibold,
                        contentColor: .destructive,
                        fontSize: 14.0,
                        accessibility: .none
                    )
                )
            }
            .map { presenter -> DetailsScreen.CellType in
                .label(presenter)
            }

        let memo: TransactionConfirmation.Model.Memo? = pendingTransaction
            .confirmations
            .filter(\.isMemo)
            .compactMap { confirmation -> TransactionConfirmation.Model.Memo? in
                guard case .memo(let memo) = confirmation else {
                    return nil
                }
                return memo
            }
            .first

        let terms: ConfirmationModel.AnyBoolOption<Bool>? = pendingTransaction
            .confirmations
            .filter(\.isTermsOfService)
            .compactMap { confirmation -> ConfirmationModel.AnyBoolOption<Bool>? in
                guard case .termsOfService(let value) = confirmation else {
                    return nil
                }
                return value
            }
            .first

        let transferAgreement: ConfirmationModel.AnyBoolOption<Bool>? = pendingTransaction
            .confirmations
            .filter(\.isTransferAgreement)
            .compactMap { confirmation -> ConfirmationModel.AnyBoolOption<Bool>? in
                guard case .transferAgreement(let value) = confirmation else {
                    return nil
                }
                return value
            }
            .first

        var memoModels: [DetailsScreen.CellType] = []
        if let memo = memo {
            let subtitle = memo.formatted?.subtitle ?? ""
            memoModel.originalTextRelay.accept(subtitle)
            memoModel
                .focusRelay
                .filter { $0 == .off(.endEditing) }
                .mapToVoid()
                .withLatestFrom(memoModel.textRelay)
                .distinctUntilChanged()
                .map { text in
                    (text: text, oldModel: memo)
                }
                .bind(to: memoUpdated)
                .disposed(by: disposeBag)
            memoModels.append(.textField(memoModel))
        }

        var checkboxModels: [DetailsScreen.CellType] = []
        if let terms = terms,
           let transferAgreement = transferAgreement
        {
            termsCheckboxViewModel
                .selectedRelay
                .distinctUntilChanged()
                .bind(to: termsUpdated)
                .disposed(by: disposeBag)

            transferCheckboxViewModel
                .selectedRelay
                .distinctUntilChanged()
                .bind(to: transferAgreementUpdated)
                .disposed(by: disposeBag)

            checkboxModels.append(
                contentsOf: [
                    .checkbox(termsCheckboxViewModel),
                    .checkbox(transferCheckboxViewModel)
                ]
            )
        }

        var disclaimer: [DetailsScreen.CellType] = []
        if TransactionFlowDescriptor.confirmDisclaimerVisibility(action: state.action) {
            let content = LabelContent(
                text: TransactionFlowDescriptor.confirmDisclaimerText(action: state.action),
                font: .main(.medium, 12),
                color: .descriptionText,
                alignment: .left,
                accessibility: .id("disclaimer")
            )
            disclaimer.append(.staticLabel(content))
        }

        let restItems: [DetailsScreen.CellType] = memoModels +
            errorModels + disclaimer + checkboxModels
        cells = [.separator] +
            bitpayItemIfNeeded +
            confirmationLineItems +
            restItems
    }

    static func confirmCtaText(state: TransactionState) -> String {
        switch state.action {
        case .swap:
            return LocalizedString.Swap.swapNow
        case .send:
            return LocalizedString.Swap.sendNow
        case .buy:
            return LocalizedString.Swap.buyNow
        case .sell:
            return LocalizedString.Swap.sellNow
        case .deposit:
            return LocalizedString.Deposit.depositNow
        case .interestTransfer:
            return LocalizedString.Transfer.transferNow
        case .withdraw,
             .interestWithdraw:
            return LocalizedString.Withdraw.withdrawNow
        case .receive,
             .viewActivity:
            fatalError("ConfirmationPageContentReducer: \(state.action) not supported.")
        }
    }

    // MARK: - Private methods

    private func setupBitPay(on presenter: DefaultLineItemCellPresenter) {
        let bitPayLogo = UIImage(named: "bitpay-logo")

        presenter.imageWidthRelay.accept(bitPayLogo?.size.width ?? 0)
        presenter.imageRelay.accept(bitPayLogo)
    }
}

extension TransactionConfirmation {
    var isCustom: Bool {
        isErrorNotice || isMemo || isBitPay || isCheckbox
    }

    var isCheckbox: Bool {
        switch self {
        case .termsOfService,
             .transferAgreement:
            return true
        default:
            return false
        }
    }

    var isBitPay: Bool {
        switch self {
        case .bitpayCountdown:
            return true
        default:
            return false
        }
    }

    var isErrorNotice: Bool {
        switch self {
        case .errorNotice:
            return true
        default:
            return false
        }
    }

    var isRequiredAgreement: Bool {
        isTermsOfService && isTransferAgreement
    }

    var isTermsOfService: Bool {
        switch self {
        case .termsOfService:
            return true
        default:
            return false
        }
    }

    var isTransferAgreement: Bool {
        switch self {
        case .transferAgreement:
            return true
        default:
            return false
        }
    }

    var isMemo: Bool {
        switch self {
        case .memo:
            return true
        default:
            return false
        }
    }
}
