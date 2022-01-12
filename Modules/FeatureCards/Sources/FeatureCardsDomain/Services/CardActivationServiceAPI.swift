// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import RxToolKit
import ToolKit

public protocol CardActivationServiceAPI: AnyObject {

    /// Cancel polling
    var cancel: AnyPublisher<Void, Error> { get }

    /// Poll for activation
    func waitForActivation(of cardId: String) -> AnyPublisher<PollResult<CardActivationState>, Error>
}
