// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class PasswordScreenPresenter {

    // MARK: - Types

    /// Confirmation route method
    typealias ConfirmHandler = (String) -> Void

    /// Dismissal route method
    typealias DismissHandler = () -> Void

    // MARK: - Exposed Properties

    let navBarStyle = Screen.Style.Bar.lightContent(
        background: .primary
    )
    let titleStyle: Screen.Style.TitleView
    let description: String
    let textFieldViewModel = TextFieldViewModel(
        with: .password,
        validator: TextValidationFactory.Password.login,
        messageRecorder: CrashlyticsRecorder()
    )
    let buttonViewModel = ButtonViewModel.primary(
        with: LocalizationConstants.continueString
    )
    let leadingButton: Screen.Style.LeadingButton

    // MARK: - Injected

    // TODO: Remove dependency
    private let authenticationCoordinator: AuthenticationCoordinator
    private let interactor: PasswordScreenInteracting
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let alertPresenter: AlertViewPresenter
    private let confirmHandler: ConfirmHandler
    private let dismissHandler: DismissHandler

    // MARK: - Private Accessors

    private let stateReducer = FormPresentationStateReducer()
    private let stateRelay = BehaviorRelay<FormPresentationState>(value: .invalid(.emptyTextField))
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        authenticationCoordinator: AuthenticationCoordinator = .shared,
        alertPresenter: AlertViewPresenter = .shared,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        interactor: PasswordScreenInteracting,
        confirmHandler: @escaping ConfirmHandler,
        dismissHandler: @escaping DismissHandler
    ) {
        self.authenticationCoordinator = authenticationCoordinator
        self.alertPresenter = alertPresenter
        self.analyticsRecorder = analyticsRecorder
        self.interactor = interactor
        self.confirmHandler = confirmHandler
        self.dismissHandler = dismissHandler

        let title: String
        switch interactor.type {
        case .login:
            title = LocalizationConstants.Authentication.DefaultPasswordScreen.title
            description = LocalizationConstants.Authentication.DefaultPasswordScreen.description
            leadingButton = .none
        case .importPrivateKey:
            title = LocalizationConstants.Authentication.ImportKeyPasswordScreen.title
            description = LocalizationConstants.Authentication.ImportKeyPasswordScreen.description
            leadingButton = .close
        case .actionRequiresPassword:
            title = LocalizationConstants.Authentication.DefaultPasswordScreen.title
            description = LocalizationConstants.Authentication.DefaultPasswordScreen.description
            leadingButton = .close
        case .etherService:
            title = LocalizationConstants.Authentication.EtherPasswordScreen.title
            description = LocalizationConstants.Authentication.EtherPasswordScreen.description
            leadingButton = .close
        }

        titleStyle = Screen.Style.TitleView.text(value: title)

        let stateObservable = textFieldViewModel.state
            .map(weak: self) { (self, payload) -> FormPresentationState in
                try self.stateReducer.reduce(states: [payload])
            }
            /// Should never get to `catchErrorJustReturn`.
            .catchErrorJustReturn(.invalid(.invalidTextField))
            .share(replay: 1)

        stateObservable
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        stateObservable
            .map(\.isValid)
            .bindAndCatch(to: buttonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        textFieldViewModel.state
            .compactMap(\.value)
            .bindAndCatch(to: interactor.passwordRelay)
            .disposed(by: disposeBag)

        buttonViewModel.tapRelay
            .bind { [unowned self] in
                if self.interactor.isValid {
                    confirmHandler(interactor.passwordRelay.value)
                } else {
                    self.alertPresenter.standardError(
                        message: LocalizationConstants.Authentication.secondPasswordIncorrect
                    )
                }
            }
            .disposed(by: disposeBag)
    }

    func navigationBarLeadingButtonPressed() {
        dismissHandler()
    }

    func viewDidDisappear() {
        authenticationCoordinator.isShowingSecondPasswordScreen = false
    }

    func viewWillAppear() {
        analyticsRecorder.record(event: AnalyticsEvents.Onboarding.loginSecondPasswordViewed)
        authenticationCoordinator.isShowingSecondPasswordScreen = true
    }
}
