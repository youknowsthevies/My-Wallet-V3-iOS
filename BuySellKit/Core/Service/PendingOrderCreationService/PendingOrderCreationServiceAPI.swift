//
//  PendingOrderCreationServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol PendingOrderCreationServiceAPI: class {
    func create(using candidateOrderDetails: CandidateOrderDetails) -> Single<PendingConfirmationCheckoutData>
}
