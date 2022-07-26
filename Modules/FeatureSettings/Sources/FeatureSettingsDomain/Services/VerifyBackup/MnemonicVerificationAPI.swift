// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

// TICKET: IOS-2848 - Move Mnemonic Verification Logic from JS to Swift
protocol MnemonicVerificationAPI: AnyObject {
    var isVerified: AnyPublisher<Bool, Never> { get }

    func verifyMnemonicAndSync() -> AnyPublisher<EmptyValue, MnemonicVerificationServiceError>
}
