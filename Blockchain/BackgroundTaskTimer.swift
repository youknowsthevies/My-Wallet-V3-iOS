//
//  BackgroundTaskTimer.swift
//  Blockchain
//
//  Created by Paulo on 18/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit

/// BackgroundTaskTimer provides a way to delay the app suspension for a pre-defined amount of time
class BackgroundTaskTimer {

    let timeInterval: TimeInterval
    /// weak refernece to Timer added to the RunLoop
    weak var timer: Timer!
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    init(timeInterval: TimeInterval = 180) {
        self.timeInterval = timeInterval
    }

    var debugDescription: String {
        "\(self) timer: \(timer?.debugDescription ?? "nil"), backgroundTaskID: \(backgroundTaskID)"
    }

    /// Stop timer
    func stop() {
        Logger.shared.debug("\(debugDescription)")
        timer?.invalidate()
        timer = nil
    }

    /// Begin timer
    func begin(_ application: UIApplication, block: @escaping () -> Void) {
        stop()
        Logger.shared.debug("\(debugDescription)")
        /// Tells `application: UIApplication` that we are beginning a background task, expiration handler
        /// stops timer, executes given block, and ends background task
        backgroundTaskID = application.beginBackgroundTask(withName: "Delayed Background") {
            self.stop()
            block()
            application.endBackgroundTask(self.backgroundTaskID)
            self.backgroundTaskID = .invalid
        }
        /// Creates timer that will execute block and end background task after a pre-defined amount of time
        let timer = Timer(timeInterval: timeInterval, repeats: false, block: { _ in
            block()
            application.endBackgroundTask(self.backgroundTaskID)
            self.backgroundTaskID = .invalid
        })
        self.timer = timer
        /// Adds timer to current RunLoop
        RunLoop.current.add(timer, forMode: .default)
        Logger.shared.debug(" END \(debugDescription)")
    }
}
