// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol CardDeletionClientAPI: AnyObject {

    func deleteCard(by id: String) -> AnyPublisher<Void, NabuNetworkError>
}
