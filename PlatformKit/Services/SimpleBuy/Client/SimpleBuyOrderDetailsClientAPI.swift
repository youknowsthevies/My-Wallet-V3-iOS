//
//  SimpleBuyOrderDetailsClientAPI.swift
//  PlatformKit
//
//  Created by Paulo on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyOrderDetailsClientAPI: class {

    /// Fetch all Simple Buy Orders Details
    func orderDetails(token: String) -> Single<[SimpleBuyOrderDetailsResponse]>
}
