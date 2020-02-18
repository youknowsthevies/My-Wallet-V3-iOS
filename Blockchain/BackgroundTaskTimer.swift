//
//  BackgroundTaskTimer.swift
//  Blockchain
//
//  Created by Paulo on 18/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit

class BackgroundTaskTimer {

    var timer: Timer!
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    var debugDescription: String {
        "\(self) timer: \(timer?.debugDescription ?? "nil"), backgroundTaskID: \(backgroundTaskID)"
    }

    func stop() {
        Logger.shared.debug("\(debugDescription)")
        self.timer?.invalidate()
        self.timer = nil
    }

    func begin(_ application: UIApplication, block: @escaping () -> Void) {
        self.stop()
        Logger.shared.debug("\(debugDescription)")
        self.backgroundTaskID = application.beginBackgroundTask(withName: "Delayed Background") {
            self.timer?.invalidate()
            self.timer = nil
            block()
            application.endBackgroundTask(self.backgroundTaskID)
            self.backgroundTaskID = .invalid
        }
        self.timer = Timer(timeInterval: 4, repeats: false, block: { _ in
            block()
            application.endBackgroundTask(self.backgroundTaskID)
            self.backgroundTaskID = .invalid
        })
        RunLoop.current.add(timer, forMode: .default)
        Logger.shared.debug(" END \(debugDescription)")
    }
}
