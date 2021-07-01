// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

/// Types adopting `BackgroundAppHandlerAPI` should be able to handle app state actions
public protocol BackgroundAppHandlerAPI {
    func appEnteredBackground(_ application: UIApplication) -> AnyPublisher<Void, Never>
    func appEnteredForeground(_ application: UIApplication) -> AnyPublisher<Void, Never>
}

final class BackgroundAppHandler: BackgroundAppHandlerAPI {
    let backgroundTaskTimer: BackgroundTaskTimer

    init(backgroundTaskTimer: BackgroundTaskTimer) {
        self.backgroundTaskTimer = backgroundTaskTimer
    }

    func appEnteredBackground(_ application: UIApplication) -> AnyPublisher<Void, Never> {
        Deferred { [backgroundTaskTimer] in
            Future<Void, Never> { promise in
                backgroundTaskTimer.begin(application) {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func appEnteredForeground(_ application: UIApplication) -> AnyPublisher<Void, Never> {
        Deferred { [backgroundTaskTimer] in
            Future<Void, Never> { promise in
                backgroundTaskTimer.stop(application)
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}
