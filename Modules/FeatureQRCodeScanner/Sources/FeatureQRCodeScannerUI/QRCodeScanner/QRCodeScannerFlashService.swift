// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
import Combine

/// Simple service for enabling and disabling the flash on the users
/// camera. Useful in dark settings.
final class QRCodeScannerFlashService {

    /// Is the flash enabled
    var isEnabled: AnyPublisher<Bool, Never> {
        isEnabledRelay.eraseToAnyPublisher()
    }

    /// Whether or not the flash is enabled
    let isEnabledRelay = CurrentValueSubject<Bool, Never>(false)

    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if device.torchMode == .off {
                try device.setTorchModeOn(level: 1.0)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            // no-op
        }
        isEnabledRelay.send(device.torchMode == .on)
    }
}
