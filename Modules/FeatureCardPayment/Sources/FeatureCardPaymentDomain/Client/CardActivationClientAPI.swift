// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError

public protocol CardActivationClientAPI: AnyObject {

    func activateCard(
        by id: String,
        url: String,
        cvv: String
    ) -> AnyPublisher<ActivateCardResponse.Partner, NabuNetworkError>
}
