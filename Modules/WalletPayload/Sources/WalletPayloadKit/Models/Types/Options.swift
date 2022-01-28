// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public final class Options: Equatable {
    public internal(set) var pbkdf2Iterations: Int
    public internal(set) var feePerKB: Int
    public internal(set) var html5Notifications: Bool
    public internal(set) var logoutTime: Int

    static var `default` = Options(
        pbkdf2Iterations: 5000,
        feePerKB: 10000,
        html5Notifications: false,
        logoutTime: 600000
    )

    public init(
        pbkdf2Iterations: Int,
        feePerKB: Int,
        html5Notifications: Bool,
        logoutTime: Int
    ) {
        self.pbkdf2Iterations = pbkdf2Iterations
        self.feePerKB = feePerKB
        self.html5Notifications = html5Notifications
        self.logoutTime = logoutTime
    }
}

extension Options {
    public static func == (lhs: Options, rhs: Options) -> Bool {
        lhs.pbkdf2Iterations == rhs.pbkdf2Iterations
            && lhs.feePerKB == rhs.feePerKB
            && lhs.html5Notifications == rhs.html5Notifications
            && lhs.logoutTime == rhs.logoutTime
    }
}
