// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

struct SingleSignOnEnvironment {
    init(mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.mainQueue = mainQueue
    }

    var mainQueue: AnySchedulerOf<DispatchQueue>
}
