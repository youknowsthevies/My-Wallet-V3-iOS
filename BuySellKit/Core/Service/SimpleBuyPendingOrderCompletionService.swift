//
//  SimpleBuyPendingOrderCompletionService.swift
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

public final class SimpleBuyPendingOrderCompletionService: SimpleBuyPendingOrderCompletionServiceAPI {
    
    // MARK: - Types
    
    private enum Constant {
        /// Duration in seconds
        static let pollingDuration: TimeInterval = 60
    }
    
    private let pollService: PollService<SimpleBuyOrderDetails>
    private let ordersService: SimpleBuyOrdersServiceAPI
    
    // MARK: - Setup
    
    public init(ordersService: SimpleBuyOrdersServiceAPI) {
        self.ordersService = ordersService
        pollService = .init(matcher: { $0.isFinal })
    }
    
    public func waitForFinalizedState(of orderId: String) -> Single<SimpleBuyPolledOrder> {
        pollService.setFetch(weak: self) { (self) in
            self.ordersService
                .fetchOrder(with: orderId)
        }
        return pollService.poll(timeoutAfter: Constant.pollingDuration)
    }
}
