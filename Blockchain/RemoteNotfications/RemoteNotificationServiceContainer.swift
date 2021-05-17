// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Remote notification service container provides maximum abstraction
/// for notification authorization, registration, sending and emitting services.
final class RemoteNotificationServiceContainer {

    // MARK: - Types

    typealias Service = RemoteNotificationServicing & RemoteNotificationTokenSending & RemoteNotificationDeviceTokenReceiving

    // MARK: - Properties

    /// A default container instance - provides a container with default services
    /// Test-suites should create their own container.
    static let `default` = RemoteNotificationServiceContainer()

    /// Emitter of notification enums
    var emitter: RemoteNotificationEmitting {
        service.relay
    }

    /// Authorizer of remote notifications
    var authorizer: RemoteNotificationAuthorizing {
        service.authorizer
    }

    /// Token sender
    var tokenSender: RemoteNotificationTokenSending {
        service
    }

    /// Token receiver
    var tokenReceiver: RemoteNotificationDeviceTokenReceiving {
        service
    }

    /// Aggregates common remote notification logic
    private let service: Service

    // MARK: - Setup

    init(service: Service = RemoteNotificationService()) {
        self.service = service
    }
}
