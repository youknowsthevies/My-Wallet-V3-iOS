// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import ToolKit

public protocol CardAcquirersRepositoryAPI: AnyObject {

    /// Activated card acquirers for the current user.
    var eligibleCardAcquirers: AnyPublisher<[PaymentCardAcquirer], NabuNetworkError> { get }

    /// Returns the card tokenized with all eligible card acquirers as `[ACQUIRER_CODE: TOKEN]`.
    func tokenize(_ card: CardData) -> AnyPublisher<[String: String], Never>

    /// Returns the authorization state to display 3DS verification if needed.
    func authorizationState(
        for acquirer: ActivateCardResponse.CardAcquirer
    ) -> AnyPublisher<PartnerAuthorizationData.State, Error>
}
