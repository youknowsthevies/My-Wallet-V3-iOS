// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NabuNetworkError
import ToolKit

public protocol CardListRepositoryAPI: AnyObject {

    /// Streams an updated array of cards.
    /// Expected to reactively stream the updated cards after
    var cards: AnyPublisher<[CardData], Never> { get }

    func card(by identifier: String) -> AnyPublisher<CardData?, Never>

    func fetchCardList() -> AnyPublisher<[CardData], Never>
}
