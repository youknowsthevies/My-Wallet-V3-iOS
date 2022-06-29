// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol RecoveryPhraseStatusProviding {
    var isRecoveryPhraseVerified: Bool { get }
    var isRecoveryPhraseVerifiedPublisher: AnyPublisher<Bool, Never> { get }
    var fetchTriggerSubject: PassthroughSubject<Void, Never> { get }
}
