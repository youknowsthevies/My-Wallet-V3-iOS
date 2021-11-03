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
        .BANK_TRANSFER_ACCOUNT_NAME_MISMATCH: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_NAME_MISMATCH.title,
                subtitle: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_NAME_MISMATCH.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_NAME_MISMATCH.action, action: .request),
                .cancel
            ]
        ),
        .BANK_TRANSFER_ACCOUNT_EXPIRED: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_EXPIRED.title,
                subtitle: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_EXPIRED.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_EXPIRED.action, action: .request),
                .cancel
            ]
        ),
        .BANK_TRANSFER_ACCOUNT_FAILED: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_FAILED.title,
                subtitle: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_FAILED.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Action.tryAgain, action: .request),
                .cancel
            ]
        ),
        .BANK_TRANSFER_ACCOUNT_REJECTED: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_REJECTED.title,
                subtitle: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_REJECTED.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_REJECTED.action, action: .request),
                .cancel
            ]
        ),
        .BANK_TRANSFER_ACCOUNT_INVALID: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_INVALID.title,
                subtitle: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_INVALID.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_INVALID.action, action: .request),
                .cancel
            ]
        ),
        .BANK_TRANSFER_ACCOUNT_ALREADY_LINKED: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_ALREADY_LINKED.title,
                subtitle: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_ALREADY_LINKED.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_ALREADY_LINKED.action, action: .request),
                .cancel
            ]
        ),
        .BANK_TRANSFER_ACCOUNT_NOT_SUPPORTED: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_NOT_SUPPORTED.title,
                subtitle: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_NOT_SUPPORTED.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_NOT_SUPPORTED.action, action: .request),
                .cancel
            ]
        ),
        .BANK_TRANSFER_ACCOUNT_FAILED_INTERNAL: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_FAILED_INTERNAL.title,
                subtitle: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_FAILED_INTERNAL.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_FAILED_INTERNAL.action, action: .request),
                .cancel
            ]
        ),
        .BANK_TRANSFER_ACCOUNT_REJECTED_FRAUD: .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_REJECTED_FRAUD.title,
                subtitle: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_REJECTED_FRAUD.subtitle
            ),
            action: [
                .retry(label: Localization.Bank.Error.BANK_TRANSFER_ACCOUNT_REJECTED_FRAUD.action, action: .request),
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
