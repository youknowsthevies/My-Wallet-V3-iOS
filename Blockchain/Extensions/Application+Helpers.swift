//
//  UIApplication.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import SafariServices

extension UIApplication {
    @objc func openWebView(url: String, title: String, presentingViewController: UIViewController) {
        guard let value = URL(string: url) else { return }
        let controller = SFSafariViewController(url: value)
        presentingViewController.present(controller, animated: true)
    }

    // Opens the mail application, if possible, otherwise, displays an error
    @objc func openMailApplication() {
        guard let mailURL = URL(string: "\(Constants.Schemes.mail)://"), canOpenURL(mailURL) else {
            AlertViewPresenter.shared.standardError(
                message: NSString(
                    format: LocalizationConstants.Errors.cannotOpenURLArg as NSString,
                    Constants.Schemes.mail
                ) as String
            )
            return
        }
        open(mailURL)
    }

    // MARK: - Open the AppStore at the app's page

    @objc func openAppStore() {
        let url = URL(string: "\(Constants.Url.appStoreLinkPrefix)\(Constants.AppStore.AppID)")!
        self.open(url)
    }
}
