// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit

public enum ResetPasswordServiceError: Error, Equatable {
    case passwordRepositoryError(PasswordRepositoryError)
}

public protocol ResetPasswordServiceAPI {
    /// Resets the password of the currently logged in wallet
    /// - Parameters:
    ///   - newPassword: the new password to be used
    /// - Returns: An `AnyPublisher` that returns Void on success and `ResetPasswordServiceError` if failed
    func setNewPassword(newPassword: String) -> AnyPublisher<Void, ResetPasswordServiceError>
}

public final class ResetPasswordService: ResetPasswordServiceAPI {

    // MARK: - Properties

    private let passwordRepository: PasswordRepositoryAPI

    // MARK: - Setup

    public init(
        passwordRepository: PasswordRepositoryAPI = resolve()
    ) {
        self.passwordRepository = passwordRepository
    }

    // MARK: - Methods

    public func setNewPassword(newPassword: String) -> AnyPublisher<Void, ResetPasswordServiceError> {
        passwordRepository
            .set(password: newPassword)
            .flatMap { [passwordRepository] _ -> AnyPublisher<Void, ResetPasswordServiceError> in
                passwordRepository
                    .sync()
                    .mapError(ResetPasswordServiceError.passwordRepositoryError)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
