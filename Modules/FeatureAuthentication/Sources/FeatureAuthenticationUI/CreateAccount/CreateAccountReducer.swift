// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import ComposableNavigation
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

public enum CreateAccountIds {
    public struct CreationId: Hashable {}
    public struct ImportId: Hashable {}
}

public enum CreateAccountContext: Equatable {
    case importWallet(mnemonic: String)
    case createWallet

    var mnemonic: String? {
        switch self {
        case .importWallet(let mnemonic):
            return mnemonic
        case .createWallet:
            return nil
        }
    }
}

public enum CreateAccountRoute: NavigationRoute {

    private typealias LocalizedStrings = LocalizationConstants.Authentication.CountryAndStatePickers

    case countryPicker
    case statePicker

    @ViewBuilder
    public func destination(in store: Store<CreateAccountState, CreateAccountAction>) -> some View {
        switch self {
        case .countryPicker:
            WithViewStore(store) { viewStore in
                ModalContainer(
                    title: LocalizedStrings.countriesPickerTitle,
                    subtitle: LocalizedStrings.countriesPickerSubtitle,
                    onClose: viewStore.send(.set(\.$pickerSelection, nil))
                ) {
                    CountryPickerView(selectedItem: viewStore.country) {
                        viewStore.send(.set(\.$country, $0))
                    }
                }
            }

        case .statePicker:
            WithViewStore(store) { viewStore in
                ModalContainer(
                    title: LocalizedStrings.statesPickerTitle,
                    subtitle: LocalizedStrings.statesPickerSubtitle,
                    onClose: viewStore.send(.set(\.$pickerSelection, nil))
                ) {
                    StatePickerView(selectedItem: viewStore.countryState) {
                        viewStore.send(.set(\.$countryState, $0))
                    }
                }
            }
        }
    }
}

public struct CreateAccountState: Equatable, NavigationState {

    public enum InputValidationError: Equatable {
        case invalidEmail
        case weakPassword
        case termsNotAccepted
    }

    public enum InputValidationState: Equatable {
        case unknown
        case valid
        case invalid(InputValidationError)

        var isInvalid: Bool {
            switch self {
            case .invalid:
                return true
            case .valid, .unknown:
                return false
            }
        }
    }

    public enum Field: Equatable {
        case email
        case password
    }

    enum PickerSelection: Hashable {
        case country
        case state
    }

    public var context: CreateAccountContext

    // User Input
    @BindableState public var emailAddress: String
    @BindableState public var password: String
    @BindableState public var country: SearchableItem<String>
    @BindableState public var countryState: SearchableItem<String>?
    @BindableState public var termsAccepted: Bool = false

    // Form interaction
    @BindableState public var passwordFieldTextVisible: Bool = false
    public var route: RouteIntent<CreateAccountRoute>?
    @BindableState public var selectedInputField: Field?
    @BindableState var pickerSelection: PickerSelection?

    // Validation
    public var validatingInput: Bool = false
    public var passwordStrength: PasswordValidationScore
    public var inputValidationState: InputValidationState
    public var failureAlert: AlertState<CreateAccountAction>?

    public var isCreatingWallet = false

    var isCreateButtonDisabled: Bool {
        validatingInput || inputValidationState.isInvalid || isCreatingWallet
    }

    public init(
        context: CreateAccountContext,
        countries: [SearchableItem<String>] = CountryPickerView.countries,
        states: [SearchableItem<String>] = StatePickerView.usaStates,
        locale: Locale = .current
    ) {
        self.context = context
        emailAddress = ""
        password = ""
        passwordStrength = .none
        inputValidationState = .unknown
        country = countries.first(where: { String(describing: $0.id) == locale.regionCode }) ?? countries[0]
        countryState = country.id == "US" ? states[0] : nil
        failureAlert = nil
    }
}

public enum CreateAccountAction: Equatable, NavigationAction, BindableAction {
    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    case alert(AlertAction)
    case binding(BindingAction<CreateAccountState>)
    // use `createAccount` to perform the account creation. this action is fired after the user confirms the details and the input is validated.
    case createOrImportWallet(CreateAccountContext)
    case createAccount
    case importAccount(_ mnemonic: String)
    case createButtonTapped
    case didUpdatePasswordStrenght(PasswordValidationScore)
    case didUpdateInputValidation(CreateAccountState.InputValidationState)
    case openExternalLink(URL)
    case onWillDisappear
    case route(RouteIntent<CreateAccountRoute>?)
    case validatePasswordStrength
    case accountRecoveryFailed(WalletRecoveryError)
    case accountCreation(Result<WalletCreatedContext, WalletCreationServiceError>)
    case accountImported(Result<Either<WalletCreatedContext, EmptyValue>, WalletCreationServiceError>)
    // required for legacy flow
    case triggerAuthenticate
    case none
}

struct CreateAccountEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let passwordValidator: PasswordValidatorAPI
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
}

typealias CreateAccountLocalization = LocalizationConstants.FeatureAuthentication.CreateAccount

let createAccountReducer = Reducer<
    CreateAccountState,
    CreateAccountAction,
    CreateAccountEnvironment
        // swiftlint:disable:next closure_body_length
> { state, action, environment in
    switch action {
    case .binding(\.$emailAddress):
        state.inputValidationState = .unknown
        return .none

    case .binding(\.$password):
        state.inputValidationState = .unknown
        return Effect(value: .validatePasswordStrength)

    case .binding(\.$termsAccepted):
        state.inputValidationState = .unknown
        return .none

    case .binding(\.$country):
        if state.country.id == "US" {
            state.countryState = StatePickerView.usaStates[0]
        } else {
            state.countryState = nil
        }
        return Effect(value: .set(\.$pickerSelection, nil))

    case .binding(\.$countryState):
        return Effect(value: .set(\.$pickerSelection, nil))

    case .binding(\.$pickerSelection):
        guard let selection = state.pickerSelection else {
            return Effect(value: .dismiss())
        }
        state.selectedInputField = nil
        switch selection {
        case .country:
            return .enter(into: .countryPicker, context: .none)
        case .state:
            return .enter(into: .statePicker, context: .none)
        }

    case .createAccount:
        // by this point we have validated all the fields neccessary
        state.isCreatingWallet = true
        let accountName = CreateAccountLocalization.defaultAccountName
        return .merge(
            Effect(value: .triggerAuthenticate),
            environment.walletCreationService
                .createWallet(
                    state.emailAddress,
                    state.password,
                    accountName
                )
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: CreateAccountIds.CreationId(), cancelInFlight: true)
                .map(CreateAccountAction.accountCreation)
        )

    case .createOrImportWallet(.createWallet):
        return Effect(value: .createAccount)
    case .createOrImportWallet(.importWallet(let mnemonic)):
        return Effect(value: .importAccount(mnemonic))

    case .importAccount(let mnemonic):
        state.isCreatingWallet = true
        let accountName = CreateAccountLocalization.defaultAccountName
        return .merge(
            Effect(value: .triggerAuthenticate),
            environment.walletCreationService
                .importWallet(
                    state.emailAddress,
                    state.password,
                    accountName,
                    mnemonic
                )
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: CreateAccountIds.ImportId(), cancelInFlight: true)
                .map(CreateAccountAction.accountImported)
        )

    case .accountCreation(.failure(let error)),
         .accountImported(.failure(let error)):
        state.isCreatingWallet = false
        let title = LocalizationConstants.Errors.error
        let message = error.localizedDescription
        return .merge(
            Effect(
                value: .alert(
                    .show(title: title, message: message)
                )
            ),
            .cancel(id: CreateAccountIds.CreationId()),
            .cancel(id: CreateAccountIds.ImportId())
        )

    case .accountCreation(.success(let context)),
         .accountImported(.success(.left(let context))):
        return .concatenate(
            Effect(value: .triggerAuthenticate),
            .merge(
                .cancel(id: CreateAccountIds.CreationId()),
                .cancel(id: CreateAccountIds.ImportId()),
                environment.walletCreationService
                    .setResidentialInfo(state.country.id.description, state.countryState?.id.description)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .fireAndForget(),
                environment.walletFetcherService
                    .fetchWallet(context.guid, context.sharedKey, context.password)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { _ in CreateAccountAction.none }
            )
        )

    case .accountImported(.success(.right(.noValue))):
        // this will only be true in case of legacy wallet
        return .cancel(id: CreateAccountIds.ImportId())

    case .createButtonTapped:
        state.validatingInput = true
        state.selectedInputField = nil
        guard state.emailAddress.isEmail else {
            return Effect(value: .didUpdateInputValidation(.invalid(.invalidEmail)))
        }
        let didAcceptTerm = state.termsAccepted
        return environment
            .passwordValidator
            .validate(password: state.password)
            .map { passwordStrength -> CreateAccountState.InputValidationState in
                guard passwordStrength.isValid else {
                    return .invalid(.weakPassword)
                }
                guard didAcceptTerm else {
                    return .invalid(.termsNotAccepted)
                }
                return .valid
            }
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> CreateAccountAction in
                guard case .success(let validationState) = result else {
                    return .didUpdateInputValidation(.unknown)
                }
                return .didUpdateInputValidation(validationState)
            }

    case .didUpdatePasswordStrenght(let score):
        state.passwordStrength = score
        return .none

    case .didUpdateInputValidation(let validationState):
        state.validatingInput = false
        state.inputValidationState = validationState
        guard validationState == .valid else {
            return .none
        }
        return Effect(value: .createOrImportWallet(state.context))

    case .openExternalLink(let url):
        environment.externalAppOpener.open(url)
        return .none

    case .onWillDisappear:
        return .none

    case .route(let route):
        state.route = route
        return .none

    case .validatePasswordStrength:
        return environment
            .passwordValidator
            .validate(password: state.password)
            .map(CreateAccountAction.didUpdatePasswordStrenght)
            .receive(on: environment.mainQueue)
            .eraseToEffect()

    case .accountRecoveryFailed(let error):
        let title = LocalizationConstants.Errors.error
        let message = error.localizedDescription
        return Effect(value: .alert(.show(title: title, message: message)))

    case .alert(.show(let title, let message)):
        state.failureAlert = AlertState(
            title: TextState(verbatim: title),
            message: TextState(verbatim: message),
            dismissButton: .default(
                TextState(LocalizationConstants.okString),
                action: .send(.alert(.dismiss))
            )
        )
        return .none

    case .alert(.dismiss):
        state.failureAlert = nil
        return .none

    case .triggerAuthenticate:
        return .none

    case .none:
        return .none

    case .binding:
        return .none
    }
}
.binding()
.analytics()

// MARK: - Private

extension Reducer where
    Action == CreateAccountAction,
    State == CreateAccountState,
    Environment == CreateAccountEnvironment
{
    /// Helper function for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                CreateAccountState,
                CreateAccountAction,
                CreateAccountEnvironment
            > { state, action, environment in
                switch action {
                case .onWillDisappear:
                    if case .importWallet = state.context {
                        environment.analyticsRecorder.record(
                            event: .importWalletCancelled
                        )
                    }
                    return .none
                case .createButtonTapped:
                    if case .importWallet = state.context {
                        environment.analyticsRecorder.record(
                            event: .importWalletConfirmed
                        )
                    }
                    return .none
                case .accountCreation(.success):
                    environment.analyticsRecorder.record(
                        event: AnalyticsEvents.New.SignUpFlow.walletSignedUp
                    )
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
