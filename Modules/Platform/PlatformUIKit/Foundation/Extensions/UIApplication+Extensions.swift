// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization
import UIKit

public protocol URLOpener {

    func open(_ url: URL, completionHandler: @escaping (Bool) -> Void)
}

public protocol ExternalAppOpener: URLOpener {

    func openMailApp(completionHandler: @escaping (Bool) -> Void)
    func openSettingsApp(completionHandler: @escaping (Bool) -> Void)
}

public extension ExternalAppOpener {

    func openMailApp(completionHandler: @escaping (Bool) -> Void) {
        guard let url = URL(string: "message://") else {
            completionHandler(false)
            return
        }
        open(url, completionHandler: completionHandler)
    }

    func openSettingsApp(completionHandler: @escaping (Bool) -> Void) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            completionHandler(false)
            return
        }
        open(url, completionHandler: completionHandler)
    }
}

extension UIApplication: ExternalAppOpener {

    public func open(_ url: URL, completionHandler: @escaping (Bool) -> Void) {
        guard canOpenURL(url) else {
            completionHandler(false)
            return
        }
        open(url, options: [.universalLinksOnly: false], completionHandler: completionHandler)
    }
}

extension UIApplication {

    /// Opens the mail application, if possible, otherwise, displays an error
    public func openMailApplication() {
        openMailApp { success in
            guard success else {
                let message = String(format: LocalizationConstants.Errors.cannotOpenURLArg, "message://")
                AlertViewPresenter.shared.standardError(message: message)
                return
            }
        }
    }
}
