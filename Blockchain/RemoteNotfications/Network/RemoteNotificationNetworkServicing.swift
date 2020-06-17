//
//  RemoteNotificationNetworkServicing.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol RemoteNotificationNetworkServicing: class {
    func register(with deviceToken: String,
                  using credentialsProvider: SharedKeyRepositoryAPI & GuidRepositoryAPI) -> Single<Void>
}
