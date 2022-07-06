// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import ToolKit

public protocol CardListServiceAPI: AnyObject {

    /// Streams an updated array of cards.
    /// Expected to reactively stream the updated cards after
    var cards: AnyPublisher<[CardData], Never> { get }

    func card(by identifier: String) -> AnyPublisher<CardData?, Never>

    func fetchCards() -> AnyPublisher<[CardData], Never>

    func doesCardExist(number: String, expiryMonth: String, expiryYear: String) -> AnyPublisher<Bool, Never>
}
