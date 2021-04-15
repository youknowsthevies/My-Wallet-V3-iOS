//
//  SwapOrder.swift
//  TransactionKit
//
//  Created by Alex McGregor on 10/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
 
struct SwapOrder {
    let identifier: String
    let state: SwapActivityItemEvent.EventStatus
    let depositAddress: String?
    
    init(identifier: String,
         state: SwapActivityItemEvent.EventStatus,
         depositAddress: String? = nil) {
        self.identifier = identifier
        self.state = state
        self.depositAddress = depositAddress
    }
}
