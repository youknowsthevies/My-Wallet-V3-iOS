// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import UIKit

public struct CardTokenizationResponse {
    public init(token: String, accounts: [String]) {
        self.token = token
        self.accounts = accounts
    }

    public let token: String
    public let accounts: [String]

    public var params: [String: String] {
        accounts.reduce(into: [String: String]()) { params, code in
            params[code] = token
        }
    }
}

public enum CardAcquirerError: Error {
    case emptyPublishableKey
    case missingParameters
    case unknownAcquirer
    case networkError(Error)
    case clientError(Error)
    case unknown
}

public protocol CardAcquirerClientAPI {
    func tokenize(_ card: CardData, accounts: [String]) -> AnyPublisher<CardTokenizationResponse, CardAcquirerError>
    static func authorizationState(
        _ acquirer: ActivateCardResponse.CardAcquirer
    ) -> PartnerAuthorizationData.State
}
