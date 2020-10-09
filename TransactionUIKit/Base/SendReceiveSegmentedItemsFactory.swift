//
//  SendReceiveSegmentedItemsFactory.swift
//  TransactionUIKit
//
//  Created by Paulo on 15/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformUIKit

class SendReceiveSegmentedItemsFactory {
    
    // MARK: Types
    
    private typealias LocalizedSend = LocalizationConstants.Send
    private typealias LocalizedReceive = LocalizationConstants.Receive
    
    // MARK: Private Properties
    
    private let builder: Builder
    
    // MARK: Setup
    
    init(builder: Builder) {
        self.builder = builder
    }
    
    func createItems() -> [SegmentedViewScreenItem] {
        [
            SegmentedViewScreenItem(title: LocalizedSend.Text.send, viewController: builder.send()),
            SegmentedViewScreenItem(title: LocalizedReceive.Text.receive, viewController: builder.receive())
        ]
    }
}
