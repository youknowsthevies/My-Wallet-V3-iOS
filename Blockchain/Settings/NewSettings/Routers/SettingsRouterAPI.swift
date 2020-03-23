//
//  SettingsRouterAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 3/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxRelay

protocol SettingsRouterAPI: Router, RoutingPreviousStateEmitterAPI {
    var actionRelay: PublishRelay<SettingsScreenAction> { get }
    func presentSettings()
    func presentSettingsAndThen(handle action: SettingsScreenAction)
}
