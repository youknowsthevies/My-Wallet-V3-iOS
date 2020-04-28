//
//  CardActivationServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 14/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public protocol CardActivationServiceAPI: class {
    var cancel: Completable { get }
    func waitForActivation(of cardId: String) -> Single<PollResult<CardActivationService.State>>
}
