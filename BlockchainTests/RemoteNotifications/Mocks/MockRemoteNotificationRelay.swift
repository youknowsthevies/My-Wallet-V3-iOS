//
//  MockRemoteNotificationRelay.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

@testable import Blockchain

final class MockRemoteNotificationRelay: RemoteNotificationEmitting {
    let relay = PublishRelay<RemoteNotification.NotificationType>()
    var notification: Observable<RemoteNotification.NotificationType> {
        relay.asObservable()
    }
}
