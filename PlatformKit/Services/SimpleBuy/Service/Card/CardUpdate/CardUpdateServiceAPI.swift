//
//  CardUpdateServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 14/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// A service API that aggregates card addition logic
public protocol CardUpdateServiceAPI: class {
    func add(card: CardData) -> Single<PartnerAuthorizationData>
}
