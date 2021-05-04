// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FirebaseDynamicLinks
import PlatformKit
import PlatformUIKit
import ToolKit

final class UserActivityHandler {

    private let deepLinkHandler: DeepLinkHandling
    private let alertPresenter: AlertViewPresenterAPI

    init(deepLinkHandler: DeepLinkHandling = resolve(),
         alertPresenter: AlertViewPresenterAPI = resolve()) {
        self.deepLinkHandler = deepLinkHandler
        self.alertPresenter = alertPresenter
    }

    func handle(userActivity: NSUserActivity) -> Bool {
        guard let webpageUrl = userActivity.webpageURL else { return false }

        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(webpageUrl) { [weak self] dynamicLink, error in
            guard error == nil else {
                Logger.shared.error("Got error handling universal link: \(error!.localizedDescription)")
                return
            }

            guard let deepLinkUrl = dynamicLink?.url else {
                return
            }

            // Check that the version of the link (if provided) is supported, if not, prompt the user to update
            if let minimumAppVersionStr = dynamicLink?.minimumAppVersion,
                let minimumAppVersion = AppVersion(string: minimumAppVersionStr),
                let appVersionStr = Bundle.applicationVersion,
                let appVersion = AppVersion(string: appVersionStr),
                appVersion < minimumAppVersion {
                self?.showUpdateAppAlert()
                return
            }

            Logger.shared.info("Deeplink: \(deepLinkUrl.absoluteString)")
            self?.deepLinkHandler.handle(deepLink: deepLinkUrl.absoluteString)
        }
        return handled
    }

    private func showUpdateAppAlert() {
        let actions = [
            UIAlertAction(title: LocalizationConstants.DeepLink.updateNow, style: .default, handler: { _ in
                UIApplication.shared.openAppStore()
            }),
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        ]
        alertPresenter.notify(
            content: AlertViewContent(
                title: LocalizationConstants.DeepLink.deepLinkUpdateTitle,
                message: LocalizationConstants.DeepLink.deepLinkUpdateMessage,
                actions: actions
            ),
            in: nil
        )
    }
}
