// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol CardDetailClientAPI: AnyObject {

    func getCard(by id: String) -> AnyPublisher<CardPayload, NabuNetworkError>
}
