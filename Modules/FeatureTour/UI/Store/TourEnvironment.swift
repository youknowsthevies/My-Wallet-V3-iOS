// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CombineSchedulers

public struct TourEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>

    var createAccountAction: () -> Void
    var restoreAction: () -> Void
    var logInAction: () -> Void

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        createAccountAction: @escaping () -> Void,
        restoreAction: @escaping () -> Void,
        logInAction: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.createAccountAction = createAccountAction
        self.restoreAction = restoreAction
        self.logInAction = logInAction
    }
}
