// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAppUI
import RxSwift
import ToolKit
import WalletPayloadKit

final class SecondPasswordPrompter: SecondPasswordPromptable {

    private let secondPasswordStore: SecondPasswordStorable
    private let secondPasswordPrompterHelper: SecondPasswordHelperAPI
    private let secondPasswordService: SecondPasswordServiceAPI

    private let nativeWalletEnabled: () -> AnyPublisher<Bool, Never>

    @LazyInject private var walletManager: WalletManager

    init(
        secondPasswordStore: SecondPasswordStorable = resolve(),
        secondPasswordPrompterHelper: SecondPasswordHelperAPI = resolve(),
        secondPasswordService: SecondPasswordServiceAPI = resolve(),
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.secondPasswordStore = secondPasswordStore
        self.secondPasswordPrompterHelper = secondPasswordPrompterHelper
        self.secondPasswordService = secondPasswordService
        self.nativeWalletEnabled = nativeWalletEnabled
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
        nativeWalletEnabled()
            .flatMap
            { [needsSecondPassword_old, secondPasswordService] isEnabled -> AnyPublisher<Bool, SecondPasswordError> in
                guard isEnabled else {
                    return needsSecondPassword_old()
                        .eraseToAnyPublisher()
                }
                return .just(secondPasswordService.walletRequiresSecondPassword)
                    .ignoreFailure()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func needsSecondPassword_old() -> AnyPublisher<Bool, SecondPasswordError> {
        Deferred { [walletManager] in
            Future { promise in
                if walletManager.wallet.isInitialized() {
                    promise(.success(walletManager.wallet.needsSecondPassword()))
                } else {
                    promise(.failure(.walletNotInitialized))
                }
            }
        }
        .subscribe(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
