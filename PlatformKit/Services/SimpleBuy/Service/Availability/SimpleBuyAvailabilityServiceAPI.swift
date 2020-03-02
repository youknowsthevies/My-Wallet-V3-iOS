//
//  SimpleBuyAvailabilityServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyAvailabilityServiceAPI: class {
    var valueObservable: Observable<Bool> { get }
    var valueSingle: Single<Bool> { get }
    func fetch() -> Single<Bool>
}
