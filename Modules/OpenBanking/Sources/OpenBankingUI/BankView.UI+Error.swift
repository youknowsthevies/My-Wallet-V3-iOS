// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit
import UIComponentsKit

extension BankState.UI {

    static func error(_ error: OpenBanking.Error) -> Self {
        switch error {
        case .code(let code):
            return errors[code, default: defaultError]
        case .message(let message):
            return .errorMessage(message)
        default:
            return defaultError
        }
    }

    static var errors: [String: Self] = [
        "NULL": defaultError,
        "BANK_TRANSFER_ACCOUNT_NAME_MISMATCH": .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: R.Bank.Error.BANK_TRANSFER_ACCOUNT_NAME_MISMATCH.title,
                subtitle: R.Bank.Error.BANK_TRANSFER_ACCOUNT_NAME_MISMATCH.subtitle
            ),
            action: [
                .retry(label: R.Bank.Action.tryADifferentBank, action: .request),
                .cancel
            ]
        ),
        "BANK_TRANSFER_ACCOUNT_EXPIRED": .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: R.Bank.Error.BANK_TRANSFER_ACCOUNT_EXPIRED.title,
                subtitle: R.Bank.Error.BANK_TRANSFER_ACCOUNT_EXPIRED.subtitle
            ),
            action: [
                .retry(label: R.Bank.Action.tryAgain, action: .request),
                .cancel
            ]
        ),
        "BANK_TRANSFER_ACCOUNT_FAILED": .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: R.Bank.Error.BANK_TRANSFER_ACCOUNT_FAILED.title,
                subtitle: R.Bank.Error.BANK_TRANSFER_ACCOUNT_FAILED.subtitle
            ),
            action: [
                .retry(label: R.Bank.Action.tryAgain, action: .request),
                .cancel
            ]
        ),
        "BANK_TRANSFER_ACCOUNT_REJECTED": .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: R.Bank.Error.BANK_TRANSFER_ACCOUNT_REJECTED.title,
                subtitle: R.Bank.Error.BANK_TRANSFER_ACCOUNT_REJECTED.subtitle
            ),
            action: [
                .retry(label: R.Bank.Action.tryAgain, action: .request),
                .cancel
            ]
        ),
        "BANK_TRANSFER_ACCOUNT_INVALID": .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: R.Bank.Error.BANK_TRANSFER_ACCOUNT_INVALID.title,
                subtitle: R.Bank.Error.BANK_TRANSFER_ACCOUNT_INVALID.subtitle
            ),
            action: [
                .retry(label: R.Bank.Action.tryAgain, action: .request),
                .cancel
            ]
        ),
        "BANK_TRANSFER_ACCOUNT_ALREADY_LINKED": .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: R.Bank.Error.BANK_TRANSFER_ACCOUNT_ALREADY_LINKED.title,
                subtitle: R.Bank.Error.BANK_TRANSFER_ACCOUNT_ALREADY_LINKED.subtitle
            ),
            action: [
                .retry(label: R.Bank.Action.tryAgain, action: .request),
                .cancel
            ]
        )
    ]

    static var defaultError: Self {
        .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: R.Bank.Error.default.title,
                subtitle: R.Bank.Error.default.subtitle
            ),
            action: [
                .retry(label: R.Bank.Action.tryAgain, action: .request),
                .cancel
            ]
        )
    }

    static func errorMessage(_ message: String) -> Self {
        .init(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .error),
                title: R.Bank.Error.default.title,
                subtitle: message
            ),
            action: [
                .retry(label: R.Bank.Action.tryAgain, action: .request),
                .cancel
            ]
        )
    }
}
