//
//  WebViewServiceAPI.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 19/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

/// A protocol for Safari services
public protocol WebViewServiceAPI: class {
    func openSafari(url: String, from parent: ViewControllerAPI)
    func openSafari(url: URL, from parent: ViewControllerAPI)
}
