// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import HDWalletKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class RecoverFundsScreenPresenter {

    /// The total state of the input
    enum State {

        /// The values associated with a `valid` state
        struct Values {
            let mneumonic: String
        }

        enum InvalidReason {
            case incompleteMnemonic
            case invalidMnemonic
            case emptyTextView
        }

        /// Valid state of input with `Values` associated
        case valid(Values)

        /// Invalid state of input with `InvalidReason` associated
        case invalid(InvalidReason)

        /// Returns `true` if state is valid
        var isValid: Bool {
            switch self {
            case .valid:
                return true
            case .invalid:
                return false
            }
        }
    }

    // MARK: - Exposed Properties

    let continueTappedRelay = PublishRelay<String>()

    let navBarStyle: Screen.Style.Bar
    let leadingButton: Screen.Style.LeadingButton
    let trailingButton: Screen.Style.TrailingButton
    let titleStyle = Screen.Style.TitleView.text(value: LocalizationConstants.Onboarding.RecoverFunds.title)
    let description = LocalizationConstants.Onboarding.RecoverFunds.description
    let mnemonicTextViewModel = MnemonicTextViewViewModel(
        validator: TextValidationFactory.Backup.mnemonic(
            words: Set(WordList.default.words)
        )
    )
    let continueButtonViewModel = ButtonViewModel.primary(
        with: LocalizationConstants.Onboarding.PasswordRequiredScreen.continueButton
    )

    /// The total state of the view model
    var state: Driver<State> {
        stateRelay.asDriver()
    }

    // MARK: - Private Properties

    /// Content relay
    private let mnemonicEntryRelay: BehaviorRelay<String> = BehaviorRelay(value: "")
    private let stateRelay = BehaviorRelay<State>(value: .invalid(.emptyTextView))
    private let disposeBag = DisposeBag()
    private let feedback = UINotificationFeedbackGenerator()

    // MARK: - Setup

    init(
        navBarStyle: Screen.Style.Bar = .lightContent(),
        leadingButton: Screen.Style.LeadingButton = .back,
        trailingButton: Screen.Style.TrailingButton = .none
    ) {
        self.navBarStyle = navBarStyle
        self.leadingButton = leadingButton
        self.trailingButton = trailingButton
        let stateObservable = mnemonicTextViewModel.state.map { payload -> State in
            switch payload {
            case .complete(let value):
                return .valid(.init(mneumonic: value.string))
            case .valid:
                return .invalid(.incompleteMnemonic)
            case .empty:
                return .invalid(.emptyTextView)
            case .invalid:
                return .invalid(.invalidMnemonic)
            }
        }
        .catchErrorJustReturn(.invalid(.invalidMnemonic))

        stateObservable
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        stateObservable
            .map(\.isValid)
            .bindAndCatch(to: continueButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        stateRelay.compactMap { [weak self] state -> String? in
            guard case .valid(let values) = state else { return nil }
            self?.feedback.prepare()
            self?.feedback.notificationOccurred(.success)
            return values.mneumonic
        }
        .bindAndCatch(to: mnemonicEntryRelay)
        .disposed(by: disposeBag)

        continueButtonViewModel.tapRelay.bind { [unowned self] _ in
            self.execute()
        }
        .disposed(by: disposeBag)
    }

    private func execute() {
        continueTappedRelay.accept(mnemonicEntryRelay.value)
    }
}
