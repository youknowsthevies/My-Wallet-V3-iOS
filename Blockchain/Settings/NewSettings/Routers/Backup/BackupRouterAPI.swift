//
//  BackupRouterAPI.swift
//  Blockchain
//
//  Created by AlexM on 2/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

protocol BackupRouterAPI: class {
    var completionRelay: PublishRelay<Void> { get }
    
    var entry: BackupRouterEntry { get }
    
    func next(to state: BackupRouterStateService.State)
    func previous()
    func start()
}
