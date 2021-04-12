//
//  BuySellSegmentedItemsFactory.swift
//  BuySellUIKit
//
//  Created by Paulo on 21/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformUIKit

// TODO: Use real screens.
class BuySellSegmentedItemsFactory {

    func createItems() -> [SegmentedViewScreenItem] {
        [
            SegmentedViewScreenItem(title: "Buy", viewController: UIViewController()),
            SegmentedViewScreenItem(title: "Sell", viewController: UIViewController())
        ]
    }
}
