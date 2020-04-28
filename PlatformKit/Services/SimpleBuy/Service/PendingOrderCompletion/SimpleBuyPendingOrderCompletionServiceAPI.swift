//
//  SimpleBuyPendingOrderCompletionServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public typealias SimpleBuyPolledOrder = PollResult<SimpleBuyOrderDetails>

public protocol SimpleBuyPendingOrderCompletionServiceAPI {
    func waitForFinalizedState(of orderId: String) -> Single<SimpleBuyPolledOrder>
}
