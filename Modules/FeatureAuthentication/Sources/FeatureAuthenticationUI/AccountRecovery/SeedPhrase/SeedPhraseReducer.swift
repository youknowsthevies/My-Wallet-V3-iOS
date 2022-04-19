// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import FeatureAuthenticationDomain
import Localization
import ToolKit

// MARK: - Type

public enum WalletRecoveryIds {
    public struct RecoveryId: Hashable {}
    public struct ImportId: Hashable {}
    public struct AccountRecoveryAfterResetId: Hashable {}
}

public enum SeedPhraseAction: Equatable {

    public enum URLContent {

        case contactSupport

        var url: URL? {
            switch self {
            case .contactSupport:
                return URL(string: Constants.SupportURL.ResetAccount.contactSupport)
            }
        }
    }

    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    case alert(AlertAction)
    case didChangeSeedPhrase(String)
    case didChangeSeedPhraseScore(MnemonicValidationScore)
    case validateSeedPhrase
    case setResetPasswordScreenVisible(Bool)
    case setResetAccountBottomSheetVisible(Bool)
    case setLostFundsWarningScreenVisible(Bool)
    case setImportWalletScreenVisible(Bool)
    case setSecondPasswordNoticeVisible(Bool)
    case resetPassword(ResetPasswordAction)
    case resetAccountWarning(ResetAccountWarningAction)
    case lostFundsWarning(LostFundsWarningAction)
    case importWallet(ImportWalletAction)
    case secondPasswordNotice(SecondPasswordNotice.Action)
    case restoreWallet(WalletRecovery)
    case restored(Result<EmptyValue, WalletRecoveryError>)
    case imported(Result<EmptyValue, WalletRecoveryError>)
    case accountCreation(Result<WalletCreatedContext, WalletCreationServiceError>)
    case triggerAuthenticate // needed for legacy wallet flow
    case open(urlContent: URLContent)
    case none
}

public enum AccountRecoveryContext: Equatable {
    case troubleLoggingIn
    case restoreWallet
    case none
}

// MARK: - Properties

public struct SeedPhraseState: Equatable {
    var context: AccountRecoveryContext
    var emailAddress: String
    var nabuInfo: WalletInfo.Nabu?
    var seedPhrase: String
    var seedPhraseScore: MnemonicValidationScore
    var isResetPasswordScreenVisible: Bool
    var isResetAccountBottomSheetVisible: Bool
    var isLostFundsWarningScreenVisible: Bool
    var isImportWalletScreenVisible: Bool
    var isSecondPasswordNoticeVisible: Bool
    var resetPasswordState: ResetPasswordState?
    var resetAccountWarningState: ResetAccountWarningState?
    var lostFundsWarningState: LostFundsWarningState?
    var importWalletState: ImportWalletState?
    var secondPasswordNoticeState: SecondPasswordNotice.State?
    var failureAlert: AlertState<SeedPhraseAction>?
    var isLoading: Bool

    var accountResettable: Bool {
        nabuInfo != nil
    }

    init(context: AccountRecoveryContext, emailAddress: String = "", nabuInfo: WalletInfo.Nabu? = nil) {
        self.context = context
        self.emailAddress = emailAddress
        self.nabuInfo = nabuInfo
        seedPhrase = ""
        seedPhraseScore = .none
        isResetPasswordScreenVisible = false
        isResetAccountBottomSheetVisible = false
        isLostFundsWarningScreenVisible = false
        isImportWalletScreenVisible = false
        isSecondPasswordNoticeVisible = false
        failureAlert = nil
        isLoading = false
    }
}

struct SeedPhraseEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let validator: SeedPhraseValidatorAPI
    let externalAppOpener: ExternalAppOpener
    let passwordValidator: PasswordValidatorAPI
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let accountRecoveryService: AccountRecoveryServiceAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        validator: SeedPhraseValidatorAPI = resolve(),
        passwordValidator: PasswordValidatorAPI = resolve(),
        externalAppOpener: ExternalAppOpener,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        walletRecoveryService: WalletRecoveryService,
        walletCreationService: WalletCreationService,
        walletFetcherService: WalletFetcherService,
        accountRecoveryService: AccountRecoveryServiceAPI
    ) {
        self.mainQueue = mainQueue
        self.validator = validator
        self.passwordValidator = passwordValidator
        self.externalAppOpener = externalAppOpener
        self.analyticsRecorder = analyticsRecorder
        self.walletRecoveryService = walletRecoveryService
        self.walletCreationService = walletCreationService
        self.walletFetcherService = walletFetcherService
        self.accountRecoveryService = accountRecoveryService
    }
}

let seedPhraseReducer = Reducer.combine(
    secondPasswordNoticeReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.secondPasswordNoticeState,
            action: /SeedPhraseAction.secondPasswordNotice,
            environment: {
                SecondPasswordNotice.Environment(
                    externalAppOpener: $0.externalAppOpener
                )
            }
        ),
    importWalletReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.importWalletState,
            action: /SeedPhraseAction.importWallet,
            environment: {
                ImportWalletEnvironment(
                    mainQueue: $0.mainQueue,
                    passwordValidator: $0.passwordValidator,
                    externalAppOpener: $0.externalAppOpener,
                    analyticsRecorder: $0.analyticsRecorder,
                    walletRecoveryService: $0.walletRecoveryService,
                    walletCreationService: $0.walletCreationService,
                    walletFetcherService: $0.walletFetcherService
                )
            }
        ),
    resetAccountWarningReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.resetAccountWarningState,
            action: /SeedPhraseAction.resetAccountWarning,
            environment: {
                ResetAccountWarningEnvironment(
                    analyticsRecorder: $0.analyticsRecorder
                )
            }
        ),
    lostFundsWarningReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.lostFundsWarningState,
            action: /SeedPhraseAction.lostFundsWarning,
            environment: {
                LostFundsWarningEnvironment(
                    mainQueue: $0.mainQueue,
                    analyticsRecorder: $0.analyticsRecorder
                )
            }
        ),
    resetPasswordReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.resetPasswordState,
            action: /SeedPhraseAction.resetPassword,
            environment: {
                ResetPasswordEnvironment(
                    mainQueue: $0.mainQueue
                )
            }
        ),
    Reducer<
        SeedPhraseState,
        SeedPhraseAction,
        SeedPhraseEnvironment
    > { state, action, environment in
        switch action {

        case .didChangeSeedPhrase(let seedPhrase):
            state.seedPhrase = seedPhrase
            return Effect(value: .validateSeedPhrase)

        case .didChangeSeedPhraseScore(let score):
            state.seedPhraseScore = score
            return .none

        case .validateSeedPhrase:
            return environment
                .validator
                .validate(phrase: state.seedPhrase)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> SeedPhraseAction in
                    guard case .success(let score) = result else {
                        return .none
                    }
                    return .didChangeSeedPhraseScore(score)
                }

        case .setResetPasswordScreenVisible(let isVisible):
            state.isResetPasswordScreenVisible = isVisible
            if isVisible {
                state.resetPasswordState = .init()
            }
            return .none

        case .setResetAccountBottomSheetVisible(let isVisible):
            state.isResetAccountBottomSheetVisible = isVisible
            if isVisible {
                state.resetAccountWarningState = .init()
            }
            return .none

        case .setLostFundsWarningScreenVisible(let isVisible):
            state.isLostFundsWarningScreenVisible = isVisible
            if isVisible {
                state.lostFundsWarningState = .init()
            }
            return .none

        case .setImportWalletScreenVisible(let isVisible):
            state.isImportWalletScreenVisible = isVisible
            if isVisible {
                state.importWalletState = .init(mnemonic: state.seedPhrase)
            }
            return .none

        case .setSecondPasswordNoticeVisible(let isVisible):
            state.isSecondPasswordNoticeVisible = isVisible
            if isVisible {
                state.secondPasswordNoticeState = .init()
            }
            return .none

        case .resetPassword:
            // handled in reset password reducer
            return .none

        case .resetAccountWarning(.retryButtonTapped),
             .resetAccountWarning(.onDisappear):
            return Effect(value: .setResetAccountBottomSheetVisible(false))

        case .resetAccountWarning(.continueResetButtonTapped):
            return .concatenate(
                Effect(value: .setResetAccountBottomSheetVisible(false)),
                Effect(value: .setLostFundsWarningScreenVisible(true))
            )

        case .lostFundsWarning(.goBackButtonTapped):
            return Effect(value: .setLostFundsWarningScreenVisible(false))

        case .lostFundsWarning(.resetPassword(.reset(let password))):
            guard let nabuInfo = state.nabuInfo else {
                return .none
            }
            let accountName = CreateAccountLocalization.defaultAccountName
            return .concatenate(
                Effect(value: .triggerAuthenticate),
                environment.walletCreationService
                    .createWallet(
                        state.emailAddress,
                        password,
                        accountName
                    )
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .cancellable(id: CreateAccountIds.CreationId(), cancelInFlight: true)
                    .map(SeedPhraseAction.accountCreation)
            )

        case .accountCreation(.failure(let error)):
            let title = LocalizationConstants.Errors.error
            let message = error.localizedDescription
            state.lostFundsWarningState?.resetPasswordState?.isLoading = false
            return .merge(
                Effect(
                    value: .alert(
                        .show(
                            title: title,
                            message: message
                        )
                    )
                ),
                .cancel(id: CreateAccountIds.CreationId())
            )

        case .accountCreation(.success(let context)):
            guard let nabuInfo = state.nabuInfo else {
                return .none
            }
            return .merge(
                .cancel(id: CreateAccountIds.CreationId()),
                // The effects of fetching a wallet still happen on the CoreCoordinator,
                // this should not be fireAndForget once we have wallet loading natively
                environment.walletFetcherService
                    .fetchWallet(context.guid, context.sharedKey, context.password)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .fireAndForget(),
                environment.accountRecoveryService
                    .recoverUser(
                        guid: context.guid,
                        sharedKey: context.sharedKey,
                        userId: nabuInfo.userId,
                        recoveryToken: nabuInfo.recoveryToken
                    )
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .cancellable(id: WalletRecoveryIds.AccountRecoveryAfterResetId(), cancelInFlight: false)
                    .map { result -> SeedPhraseAction in
                        guard case .success = result else {
                            environment.analyticsRecorder.record(
                                event: AnalyticsEvents.New.AccountRecoveryFlow.accountRecoveryFailed
                            )
                            // show recovery failures if the endpoint fails
                            return .lostFundsWarning(
                                .resetPassword(
                                    .setResetAccountFailureVisible(true)
                                )
                            )
                        }
                        environment.analyticsRecorder.record(
                            event: AnalyticsEvents.New.AccountRecoveryFlow
                                .accountPasswordReset(hasRecoveryPhrase: false)
                        )
                        return .none
                    }
            )

        case .lostFundsWarning:
            return .none

        case .importWallet(.goBackButtonTapped):
            return Effect(value: .setImportWalletScreenVisible(false))

        case .importWallet(.createAccount(.triggerAuthenticate)):
            return Effect(value: .triggerAuthenticate)

        case .importWallet:
            return .none

        case .secondPasswordNotice:
            return .none

        case .restoreWallet(.metadataRecovery(let mnemonic)):
            state.isLoading = true
            return .concatenate(
                Effect(value: .triggerAuthenticate),
                environment.walletRecoveryService
                    .recoverFromMetadata(mnemonic)
                    .receive(on: environment.mainQueue)
                    .mapError { _ in WalletRecoveryError.failedToRestoreWallet }
                    .catchToEffect()
                    .cancellable(id: WalletRecoveryIds.RecoveryId(), cancelInFlight: true)
                    .map(SeedPhraseAction.restored)
            )
        case .restoreWallet:
            return .none

        case .restored(.success):
            state.isLoading = false
            return .cancel(id: WalletRecoveryIds.RecoveryId())

        case .restored(.failure):
            state.isLoading = false
            return .merge(
                .cancel(id: WalletRecoveryIds.RecoveryId()),
                Effect(value: .setImportWalletScreenVisible(true))
            )

        case .imported(.success):
            return .cancel(id: WalletRecoveryIds.ImportId())

        case .imported(.failure(let error)):
            guard state.importWalletState != nil else {
                return .none
            }
            return Effect(value: .importWallet(.importWalletFailed(error)))

        case .open(let urlContent):
            guard let url = urlContent.url else {
                return .none
            }
            environment.externalAppOpener.open(url)
            return .none

        case .triggerAuthenticate:
            return .none

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

        case .none:
            return .none
        }
    }
)
.analytics()

// MARK: - Extension

extension Reducer where
    Action == SeedPhraseAction,
    State == SeedPhraseState,
    Environment == SeedPhraseEnvironment
{
    /// Helper reducer for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                SeedPhraseState,
                SeedPhraseAction,
                SeedPhraseEnvironment
            > { _, action, environment in
                switch action {
                case .setResetPasswordScreenVisible(true):
                    environment.analyticsRecorder.record(
                        event: .recoveryPhraseEntered
                    )
                    return .none
                case .setImportWalletScreenVisible(true):
                    environment.analyticsRecorder.record(
                        event: .recoveryPhraseEntered
                    )
                    return .none
                case .setResetAccountBottomSheetVisible(true):
                    environment.analyticsRecorder.record(
                        event: .resetAccountClicked
                    )
                    return .none
                case .setResetAccountBottomSheetVisible(false):
                    environment.analyticsRecorder.record(
                        event: .resetAccountCancelled
                    )
                    return .none
                case .setLostFundsWarningScreenVisible(true):
                    environment.analyticsRecorder.record(
                        event: .resetAccountCancelled
                    )
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
