//
//  WebViewRouterAPI.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 19/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay

/// A routing API to any web view.
public protocol WebViewRouterAPI: class {
    var launchRelay: PublishRelay<TitledLink> { get }
}

