//
//  CheckoutPageContentReducing.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 29/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

protocol CheckoutPageContentReducing {
    /// The title of the checkout screen
    var title: String { get }
    /// The `Cells` on the `CheckoutPage`
    var cells: [DetailsScreen.CellType] { get }
    var continueButtonViewModel: ButtonViewModel { get }
    var cancelButtonViewModel: ButtonViewModel { get }
}
