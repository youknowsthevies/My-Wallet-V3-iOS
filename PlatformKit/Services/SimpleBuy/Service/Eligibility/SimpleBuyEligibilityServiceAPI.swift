//
//  SimpleBuyEligibilityServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 14/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyEligibilityServiceAPI: class {
    var isEligible: Observable<Bool> { get }
    func fetch() -> Observable<Bool>
}
