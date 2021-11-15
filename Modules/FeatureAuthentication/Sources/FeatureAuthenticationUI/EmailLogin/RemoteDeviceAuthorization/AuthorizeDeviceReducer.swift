// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAuthenticationDomain
import ToolKit

// MARK: - Type

public enum AuthorizeDeviceAction: Equatable {
    case handleAuthorization(Bool)
    case showAuthorizationResult(Result<EmptyValue, AuthorizeVerifyDeviceError>)
}

public struct AuthorizeDeviceState: Equatable {
    public var loginRequestInfo: LoginRequestInfo
    public var authorizationResult: AuthorizationResult?

    public init(
        loginRequestInfo: LoginRequestInfo
    ) {
        self.loginRequestInfo = loginRequestInfo
    }
}

public struct AuthorizeDeviceEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        deviceVerificationService: DeviceVerificationServiceAPI
    ) {
        self.mainQueue = mainQueue
        self.deviceVerificationService = deviceVerificationService
    }
}

// MARK: - Properties

public let authorizeDeviceReducer = Reducer<
    AuthorizeDeviceState,
    AuthorizeDeviceAction,
    AuthorizeDeviceEnvironment
> { state, action, environment in
    switch action {
    case .handleAuthorization(let authorized):
        return environment
            .deviceVerificationService
            .authorizeVerifyDevice(
                from: state.loginRequestInfo.sessionId,
                payload: state.loginRequestInfo.base64Str,
                confirmDevice: authorized
            )
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> AuthorizeDeviceAction in
                switch result {
                case .success:
                    return .showAuthorizationResult(.success(.noValue))
                case .failure(let error):
                    return .showAuthorizationResult(.failure(error))
                }
            }
    case .showAuthorizationResult(let result):
        switch result {
        case .success:
            state.authorizationResult = .success
        case .failure(let error):
            switch error {
            case .linkExpired:
                state.authorizationResult = .linkExpired
            case .requestDenied:
                state.authorizationResult = .requestDenied
            case .network:
                state.authorizationResult = .unknown
            case .confirmationRequired:
                // not an authorization result
                break
            }
        }
        return .none
    }
}
