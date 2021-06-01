// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public struct SingleSignOnEnvironment {
    public init(mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.mainQueue = mainQueue
    }

    var mainQueue: AnySchedulerOf<DispatchQueue>
}
