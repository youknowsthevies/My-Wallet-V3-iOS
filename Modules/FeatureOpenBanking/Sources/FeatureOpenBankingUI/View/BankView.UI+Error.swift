// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit
import UIComponentsKit

extension BankState.UI {

    static func error(_ error: OpenBanking.Error) -> Self {
        switch error {
        case .message(let message):
            return .errorMessage(message)
        default:
            return errors[error, default: defaultError]
        }
    }

    static var errors: [OpenBanking.Error: Self] = [
        .bankTransferAccountNameMismatch: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountNameMismatch.title,
                subtitle: Localization.Bank.Error.bankTransferAccountNameMismatch.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountNameMismatch.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountExpired: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountExpired.title,
                subtitle: Localization.Bank.Error.bankTransferAccountExpired.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountExpired.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountFailed: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountFailed.title,
                subtitle: Localization.Bank.Error.bankTransferAccountFailed.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Action.tryAgain, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountRejected: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountRejected.title,
                subtitle: Localization.Bank.Error.bankTransferAccountRejected.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountRejected.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountInvalid: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountInvalid.title,
                subtitle: Localization.Bank.Error.bankTransferAccountInvalid.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountInvalid.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountAlreadyLinked: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountAlreadyLinked.title,
                subtitle: Localization.Bank.Error.bankTransferAccountAlreadyLinked.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountAlreadyLinked.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountNotSupported: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountNotSupported.title,
                subtitle: Localization.Bank.Error.bankTransferAccountNotSupported.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountNotSupported.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountFailedInternal: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountFailedInternal.title,
                subtitle: Localization.Bank.Error.bankTransferAccountFailedInternal.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountFailedInternal.action, action: .request),
                .cancel
            ]
        ),
        .bankTransferAccountRejectedFraud: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.bankTransferAccountRejectedFraud.title,
                subtitle: Localization.Bank.Error.bankTransferAccountRejectedFraud.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.bankTransferAccountRejectedFraud.action, action: .request),
                .cancel
            ]
        )
    ]

    static var defaultError: Self {
        .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.default.title,
                subtitle: Localization.Bank.Error.default.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.default.action, action: .request),
                .cancel
            ]
        )
    }

    static func errorMessage(_ message: String) -> Self {
        .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.default.title,
                subtitle: message
            ),
            action: [
                .retry(label: Localization.Bank.Error.default.action, action: .request),
                .cancel
            ]
        )
    }
}
