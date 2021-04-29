// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import PlatformUIKit

/// Responsible for showing an alert for recommended update and force update if needed.
protocol VersionUpdateAlertDisplaying {
    
    /**
     Notifies the user for any updates if necessary.
     - Parameter updateType: the type of the update
     */
    func displayVersionUpdateAlertIfNeeded(for updateType: WalletOptions.UpdateType)
}

extension VersionUpdateAlertDisplaying {
    func displayVersionUpdateAlertIfNeeded(for updateType: WalletOptions.UpdateType) {
        guard let rawAppVersion = Bundle.applicationVersion, let appVersion = AppVersion(string: rawAppVersion) else {
            return
        }
        
        switch updateType {
        case .recommended(latestVersion: let version) where version > appVersion:
            displayRecommendedUpdateAlert(currentVersion: rawAppVersion)
        case .forced(latestVersion: let version) where version > appVersion:
            // Treat `forced` the same way as we treat `recommended` until a full support of force update is implemeneted.
            displayRecommendedUpdateAlert(currentVersion: rawAppVersion)
        case .none, .recommended, .forced:
            break // Arrives at this cases if value `.none` or other cases haven't been satisfied.
        }
    }
    
    private func displayRecommendedUpdateAlert(currentVersion: String) {
        let updateNowAction = AlertAction(style: .default(LocalizationConstants.VersionUpdate.updateNowButton))
        let alert = AlertModel(
            headline: LocalizationConstants.VersionUpdate.title,
            body: LocalizationConstants.VersionUpdate.description,
            topNote: "\(LocalizationConstants.VersionUpdate.versionPrefix) \(currentVersion)",
            actions: [updateNowAction],
            image: UIImage(named: "logo_small"),
            style: .sheet
        )
        let alertView = AlertView.make(with: alert) { action in
            switch action.style {
            case .default:
                UIApplication.shared.openAppStore()
            default:
                break
            }
        }
        alertView.show()
    }
}
