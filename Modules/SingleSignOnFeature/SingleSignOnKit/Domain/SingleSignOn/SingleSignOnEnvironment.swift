// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public struct SingleSignOnEnvironment {

    var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.mainQueue = mainQueue
    }
}
