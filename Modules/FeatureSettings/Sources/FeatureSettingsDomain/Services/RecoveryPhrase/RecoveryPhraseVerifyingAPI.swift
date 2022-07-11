// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

public enum RecoveryPhraseVerificationError: Error {
    case verificationFailure
}

public protocol RecoveryPhraseVerifyingServiceAPI {
    var phraseComponents: [String] { get set }
    var selection: [String] { get set }

    func markBackupVerified() -> AnyPublisher<EmptyValue, RecoveryPhraseVerificationError>
}
