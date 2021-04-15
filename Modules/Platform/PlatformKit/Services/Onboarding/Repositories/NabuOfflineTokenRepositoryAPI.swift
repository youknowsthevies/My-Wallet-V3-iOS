//
//  NabuOfflineTokenRepositoryAPI.swift
//  PlatformKit
//
//  Created by Daniel on 26/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol NabuOfflineTokenRepositoryAPI: AnyObject {
    var offlineTokenResponse: Single<NabuOfflineTokenResponse> { get }
    func set(offlineTokenResponse: NabuOfflineTokenResponse) -> Completable
}
