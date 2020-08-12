//
//  DIKit.swift
//  PlatformUIKit
//
//  Created by Paulo on 30/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit

extension DependencyContainer {

    // MARK: - PlatformUIKit Module

    public static var platformUIKit = module {

        factory { UIApplication.shared as TopMostViewControllerProviding }

        factory { WebViewService() as WebViewServiceAPI }
    }
}
