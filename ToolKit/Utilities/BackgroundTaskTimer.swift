//
//  BackgroundTaskTimer.swift
//  ToolKit
//
//  Created by Paulo on 18/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

/// Wrappes an UIBackgroundTaskIdentifier
public struct BackgroundTaskIdentifier {
    /// A UIBackgroundTaskIdentifier
    public let identifier: Any
    public init(identifier: Any) {
        self.identifier = identifier
    }
}

/// Allows UIApplication Background Tasks API access
/// Extend UIApplication on main bundle, conforming to this API and relaying them to the respective UIApplication methods
public protocol ApplicationBackgroundTaskAPI {
    func beginToolKitBackgroundTask(withName taskName: String?, expirationHandler handler: (() -> Void)?) -> BackgroundTaskIdentifier
    func endToolKitBackgroundTask(_ identifier: BackgroundTaskIdentifier)
}

/// BackgroundTaskTimer provides a way to delay the app suspension for a pre-defined amount of time, it should be used only from
/// the UIApplicationDelegate `applicationDidEnterBackground(_)` and
/// `applicationWillEnterForeground(_)` methods.
public final class BackgroundTaskTimer {

    // MARK: Private Properties

    private let timeInterval: TimeInterval
    private weak var timer: Timer!
    private let invalidBackgroundTaskIdentifier: BackgroundTaskIdentifier
    private var backgroundTaskID: BackgroundTaskIdentifier
    private let name: String
    private var debugDescription: String {
        "\(self), \(timer?.debugDescription ?? "timer nil"), \(backgroundTaskID.identifier)"
    }

    // MARK: Init

    /// BackgroundTaskTimer
    /// - Parameter timeInterval: TimeInterval in seconds that the background thread is going to run for.
    /// - Parameter name: A name for the BackgroundTask.
    /// - Parameter invalidBackgroundTaskIdentifier: A BackgroundTaskIdentifier wrapping UIBackgroundTaskIdentifier.invalid.
    public init(timeInterval: TimeInterval = 180, name: String = UUID().uuidString, invalidBackgroundTaskIdentifier: BackgroundTaskIdentifier) {
        self.timeInterval = timeInterval
        self.name = name
        self.invalidBackgroundTaskIdentifier = invalidBackgroundTaskIdentifier
        self.backgroundTaskID = invalidBackgroundTaskIdentifier
    }

    // MARK: Public Methods

    /// Stop timer
    public func stop() {
        Logger.shared.debug("Stop")
        timer?.invalidate()
        timer = nil
    }

    /// Begin timer
    public func begin(_ application: ApplicationBackgroundTaskAPI, block: @escaping () -> Void) {
        stop()
        Logger.shared.debug("\(debugDescription)")
        /// Tells `application: UIApplication` that we are beginning a background task, expiration handler
        /// stops timer, executes given block, and ends background task
        backgroundTaskID = application.beginToolKitBackgroundTask(withName: name) {
            Logger.shared.debug("Task Expired")
            self.stop()
            block()
            application.endToolKitBackgroundTask(self.backgroundTaskID)
            self.backgroundTaskID = self.invalidBackgroundTaskIdentifier
        }
        /// Creates timer that will execute block and end background task after a pre-defined amount of time
        let timer = Timer(timeInterval: timeInterval, repeats: false, block: { _ in
            Logger.shared.debug("Timer Fired")
            block()
            application.endToolKitBackgroundTask(self.backgroundTaskID)
            self.backgroundTaskID = self.invalidBackgroundTaskIdentifier
        })
        self.timer = timer
        /// Adds timer to current RunLoop
        RunLoop.current.add(timer, forMode: .default)
        Logger.shared.debug("\(debugDescription)")
    }
}
