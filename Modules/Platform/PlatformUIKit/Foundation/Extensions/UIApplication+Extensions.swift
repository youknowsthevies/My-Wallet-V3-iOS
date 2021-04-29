// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

extension UIApplication {

    /// Opens the mail application, if possible, otherwise, displays an error
    public func openMailApplication() {
        let mailScheme = "message://"
        guard let mailURL = URL(string: mailScheme), canOpenURL(mailURL) else {
            let message = String(format: LocalizationConstants.Errors.cannotOpenURLArg, mailScheme)
            AlertViewPresenter.shared.standardError(message: message)
            return
        }
        open(mailURL)
    }
}
