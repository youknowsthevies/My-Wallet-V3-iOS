// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AudioToolbox
import PlatformKit
import ToolKit

/// Manager object for playing sounds in the app.
final class SoundManager {
    static let shared = SoundManager()

    private init() { }

    private lazy var beepSoundID: SystemSoundID? = {
        systemSoundID(forSoundFileName: "beep")
    }()

    private lazy var alertSoundID: SystemSoundID? = {
        systemSoundID(forSoundFileName: "alert-received")
    }()

    func playBeep() {
        play(systemSoundID: beepSoundID)
    }

    func playAlert() {
        play(systemSoundID: alertSoundID)
    }

    private func play(systemSoundID: SystemSoundID?) {
        guard let systemSoundID = systemSoundID else {
            Logger.shared.warning("Cannot play sound with nil SystemSoundID")
            return
        }
        AudioServicesPlaySystemSound(systemSoundID)
    }

    private func systemSoundID(forSoundFileName name: String) -> SystemSoundID? {
        guard let soundPath = Bundle.main.path(forResource: name, ofType: "wav") else {
            Logger.shared.warning("Could not retrieve file URL path for the sound '\(name).wav'")
            return nil
        }
        var soundID: SystemSoundID = 0
        let soundURL = URL(fileURLWithPath: soundPath)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
        return soundID
    }
}
