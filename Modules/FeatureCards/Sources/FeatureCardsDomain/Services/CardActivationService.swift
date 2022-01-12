// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MoneyKit
import NabuNetworkError
import RxToolKit
import ToolKit

final class CardActivationService: CardActivationServiceAPI {

    // MARK: - Types

    private enum Constant {
        /// Duration in seconds
        static let pollingDuration: TimeInterval = 60
    }

    // MARK: - Properties

    var cancel: AnyPublisher<Void, Error> {
        pollService.cancel.asPublisher().mapToVoid()
    }

    // MARK: - Injected

    private let pollService: PollService<CardActivationState>
    private let client: CardDetailClientAPI

    // MARK: - Setup

    init(client: CardDetailClientAPI = resolve()) {
        self.client = client
        pollService = .init(matcher: { !$0.isPending })
    }

    func waitForActivation(of cardId: String) -> AnyPublisher<PollResult<CardActivationState>, Error> {
        pollService.setFetch(weak: self) { (self) in
            self.client.getCard(by: cardId)
                .asObservable()
                .asSingle()
                .map { payload in
                    guard payload.state != .pending else {
                        return .pending
                    }
                    return CardActivationState(payload)
                }
        }

        return pollService.poll(timeoutAfter: Constant.pollingDuration).publisher.eraseToAnyPublisher()
    }
}
