// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import PlatformKit
import RemoteNotificationsKit
import RxSwift

/// A class that is a gateway to external notification service functionality
final class ExternalNotificationServiceProvider: ExternalNotificationProviding {

    // MARK: - Properties

    var token: Single<String> {
        Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.tokenFetcher.instanceID { result in
                    observer(result.singleEvent)
                }
                return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }

    private let tokenFetcher: RemoteNotificationTokenFetching
    private let messagingService: FirebaseCloudMessagingServiceAPI

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(tokenFetcher: RemoteNotificationTokenFetching = InstanceID.instanceID(),
         messagingService: FirebaseCloudMessagingServiceAPI = Messaging.messaging()) {
        self.tokenFetcher = tokenFetcher
        self.messagingService = messagingService
    }

    func subscribe(to topic: RemoteNotification.Topic) -> Single<Void> {
        Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.messagingService.subscribe(toTopic: topic.rawValue) { error in
                    if let error = error {
                        observer(.error(error))
                    } else {
                        observer(.success(()))
                    }
                }
                return Disposables.create()
        }
    }

    func didReceiveNewApnsToken(token: Data) {
        messagingService.apnsToken = token
    }
}
