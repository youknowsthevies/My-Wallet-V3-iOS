//
//  UIApplication+WebViewServiceAPI.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 19/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import SafariServices

extension UIApplication: WebViewServiceAPI {
    // Prefer using SFSafariViewController over UIWebview due to privacy and security improvements.
    // https://medium.com/ios-os-x-development/security-flaw-with-uiwebview-95bbd8508e3c
    public func openSafari(url: String, from parent: ViewControllerAPI) {
        guard let url = URL(string: url) else { return }
        openSafari(url: url, from: parent)
    }
    
    public func openSafari(url: URL, from parent: ViewControllerAPI) {
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .overFullScreen
        parent.present(viewController, animated: true, completion: nil)
    }
}
