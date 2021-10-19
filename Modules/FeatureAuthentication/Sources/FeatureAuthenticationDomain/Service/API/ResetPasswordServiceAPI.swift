// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

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
