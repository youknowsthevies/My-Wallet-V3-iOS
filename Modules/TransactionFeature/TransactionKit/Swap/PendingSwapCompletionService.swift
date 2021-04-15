//
//  PendingSwapCompletionService.swift
//  TransactionKit
//
//  Created by Alex McGregor on 11/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public typealias PolledSwapOrder = PollResult<SwapActivityItemEvent>

public protocol PendingSwapCompletionServiceAPI {
    func waitForFinalizedState(of transactionId: String) -> Single<PolledSwapOrder>
}

final class PendingSwapCompletionService: PendingSwapCompletionServiceAPI {
    
    // MARK: - Types
    
    private enum Constant {
        /// Duration in seconds
        static let pollingDuration: TimeInterval = 60
    }
    
    private let pollService: PollService<SwapActivityItemEvent>
    private let ordersService: OrderFetchingServiceAPI
    
    // MARK: - Setup
    
    init(ordersService: OrderFetchingServiceAPI = resolve()) {
        self.ordersService = ordersService
        pollService = .init(matcher: { $0.status == .complete })
    }
    
    func waitForFinalizedState(of transactionId: String) -> Single<PolledSwapOrder> {
        pollService.setFetch(weak: self) { (self) in
            self.ordersService
                .fetchTransaction(with: transactionId)
        }
        return pollService.poll(timeoutAfter: Constant.pollingDuration)
    }
}
