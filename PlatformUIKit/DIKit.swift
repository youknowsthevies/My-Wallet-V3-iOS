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
        
        single { AlertViewPresenter() }
        
        factory { () -> AlertViewPresenterAPI in
            let presenter: AlertViewPresenter = DIKit.resolve()
            return presenter as AlertViewPresenterAPI
        }
        
        single { LoadingViewPresenter() }
        
        factory { () -> LoadingViewPresenting in
            let presenter: LoadingViewPresenter = DIKit.resolve()
            return presenter
        }

        factory { UIApplication.shared as TopMostViewControllerProviding }

        factory { WebViewService() as WebViewServiceAPI }

        factory { UIPasteboard.general as Pasteboarding }
    }
}
