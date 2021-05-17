// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FirebaseMessaging

@testable import Blockchain

final class MockMessagingService: FCMServiceAPI {

    enum FakeError: Error {
        case subscriptionFailure
    }

    var apnsToken: Data?

    private(set) var topics = Set<RemoteNotification.Topic>()
    private let shouldSubscribeToTopicsSuccessfully: Bool

    init(shouldSubscribeToTopicsSuccessfully: Bool = true) {
        self.shouldSubscribeToTopicsSuccessfully = shouldSubscribeToTopicsSuccessfully
    }

    @discardableResult
    func appDidReceiveMessage(_ message: [AnyHashable: Any]) -> MessagingMessageInfo {
        MessagingMessageInfo()
    }

    func subscribe(toTopic topic: String, completion: FIRMessagingTopicOperationCompletion?) {
        if shouldSubscribeToTopicsSuccessfully {
            topics.insert(RemoteNotification.Topic(rawValue: topic)!)
            completion!(nil)
        } else {
            completion!(FakeError.subscriptionFailure)
        }
    }
}
