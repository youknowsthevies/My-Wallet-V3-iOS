// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public enum SecondPasswordError: Error {
    case walletNotInitialized
    case userDismissed
}

public protocol SecondPasswordPromptable: AnyObject {
    func secondPasswordIfNeeded(type: PasswordScreenType) -> AnyPublisher<String?, SecondPasswordError>
}
