// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import WalletPayloadKit

public final class RecoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI {

    public var phraseComponents: [String] = []
    public var selection: [String] = []

    private let verificationService: MnemonicVerificationService
    private let verifyMnemonicBackupService: VerifyMnemonicBackupServiceAPI
    private let nativeWalletEnabledFlag: () -> AnyPublisher<Bool, Never>

    public init(
        wallet: WalletRecoveryVerifing,
        verifyMnemonicBackupService: VerifyMnemonicBackupServiceAPI,
        nativeWalletEnabledFlag: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        verificationService = MnemonicVerificationService(walletRecoveryVerifier: wallet)
        self.verifyMnemonicBackupService = verifyMnemonicBackupService
        self.nativeWalletEnabledFlag = nativeWalletEnabledFlag
    }

    public func markBackupVerified() -> AnyPublisher<EmptyValue, RecoveryPhraseVerificationError> {
        nativeWalletEnabledFlag()
            .flatMap { [verificationService, verifyMnemonicBackupService] isEnabled
                -> AnyPublisher<EmptyValue, RecoveryPhraseVerificationError> in
                guard isEnabled else {
                    return verificationService.verifyMnemonicAndSync()
                        .mapError { _ in RecoveryPhraseVerificationError.verificationFailure }
                        .eraseToAnyPublisher()
                }
                return verifyMnemonicBackupService.markRecoveryPhraseAndSync()
                    .mapError { _ in RecoveryPhraseVerificationError.verificationFailure }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
