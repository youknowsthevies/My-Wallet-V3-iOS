// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import RxSwift
import ToolKit

enum SecondPasswordError: Error {
    case walletError(WalletError)
    case userDismissed
}

protocol SecondPasswordPromptable: AnyObject {
    func secondPasswordIfNeeded(type: PasswordScreenType) -> AnyPublisher<String?, SecondPasswordError>
}

final class SecondPasswordPrompter: SecondPasswordPromptable {

    private let secondPasswordStore: SecondPasswordStorable
    private let secondPasswordPrompterHelper: SecondPasswordHelperAPI
    @LazyInject private var walletManager: WalletManager

    init(
        secondPasswordStore: SecondPasswordStorable = resolve(),
        secondPasswordPrompterHelper: SecondPasswordHelperAPI = resolve()
    ) {
        self.secondPasswordStore = secondPasswordStore
        self.secondPasswordPrompterHelper = secondPasswordPrompterHelper
    }

    func secondPasswordIfNeeded(type: PasswordScreenType) -> AnyPublisher<String?, SecondPasswordError> {
        secondPasswordNeeded
            .flatMap { [weak self] needed -> AnyPublisher<String?, SecondPasswordError> in
                guard needed else {
                    return .just(nil)
                }
                guard let self = self else {
                    return .just(nil)
                }
                guard let secondPassword = self.secondPasswordStore.secondPassword.value else {
                    return self.promptForSecondPassword(type: type)
                        .optional()
                }
                return .just(secondPassword)
            }
            .eraseToAnyPublisher()
    }

    private func promptForSecondPassword(type: PasswordScreenType) -> AnyPublisher<String, SecondPasswordError> {
        Deferred { [secondPasswordPrompterHelper, secondPasswordStore] in
            Future { promise in
                secondPasswordPrompterHelper
                    .showPasswordScreen(
                        type: type,
                        confirmHandler: { secondPassword in
                            secondPasswordStore.secondPassword.mutate { $0 = secondPassword }
                            promise(.success(secondPassword))
                        },
                        dismissHandler: {
                            promise(.failure(.userDismissed))
                        }
                    )
            }
        }
        .subscribe(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private var secondPasswordNeeded: AnyPublisher<Bool, SecondPasswordError> {
        Deferred { [walletManager] in
            Future { promise in
                if walletManager.wallet.isInitialized() {
                    promise(.success(walletManager.wallet.needsSecondPassword()))
                } else {
                    promise(.failure(.notInitialized))
                }
            }
        }
        .mapError(SecondPasswordError.walletError)
        .subscribe(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
