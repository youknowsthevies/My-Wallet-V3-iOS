// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization
import UIKit

public protocol URLOpener {

    func open(_ url: URL, completionHandler: ((Bool) -> Void)?)
}

public protocol ExternalAppOpener: URLOpener {

    func openMailApp(completionHandler: ((Bool) -> Void)?)
    func openSettingsApp(completionHandler: ((Bool) -> Void)?)
}

extension ExternalAppOpener {

    public static var mailAppURLString: String {
        "message://"
    }

    public func openMailApp(completionHandler: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: UIApplication.mailAppURLString) else {
            completionHandler?(false)
            return
        }
        open(url, completionHandler: completionHandler)
    }

    public func openSettingsApp(completionHandler: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            completionHandler?(false)
            return
        }
        open(url, completionHandler: completionHandler)
    }
}

extension UIApplication: ExternalAppOpener {

    public func open(_ url: URL, completionHandler: ((Bool) -> Void)? = nil) {
        guard canOpenURL(url) else {
            completionHandler?(false)
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
                let message = String(
                    format: LocalizationConstants.Errors.cannotOpenURLArg, UIApplication.mailAppURLString
                )
                AlertViewPresenter.shared.standardError(message: message)
                return
            }
        }
    }
}
