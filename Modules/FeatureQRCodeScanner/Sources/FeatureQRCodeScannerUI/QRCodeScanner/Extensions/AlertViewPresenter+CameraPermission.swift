// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit
import UIKit

extension AlertViewPresenter {

    /// Displays an alert that the app requires permission to use the camera. The alert will display an
    /// action which then leads the user to their settings so that they can grant this permission.
    @objc public func showNeedsCameraPermissionAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: LocalizationConstants.Errors.cameraAccessDenied,
                message: LocalizationConstants.Errors.cameraAccessDeniedMessage,
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(title: LocalizationConstants.goToSettings, style: .default) { _ in
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(settingsURL)
                }
            )
            alert.addAction(
                UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
            )
            self.standardNotify(alert: alert)
        }
    }
}
