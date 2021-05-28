// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FirebaseMessaging

protocol FirebaseCloudMessagingServiceAPI: AnyObject {
    var apnsToken: Data? { get set }
    @discardableResult
    func appDidReceiveMessage(_ message: [AnyHashable: Any]) -> MessagingMessageInfo
    func subscribe(toTopic topic: String, completion: FIRMessagingTopicOperationCompletion?)
}

extension Messaging: FirebaseCloudMessagingServiceAPI {}
