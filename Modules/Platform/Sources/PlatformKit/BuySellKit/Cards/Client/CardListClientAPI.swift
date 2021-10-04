// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError

public protocol CardListClientAPI: AnyObject {

    var cardList: AnyPublisher<[CardPayload], NabuNetworkError> { get }
}
