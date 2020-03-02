//
//  CheckoutSummaryTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 1/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

/// A cell that is typically first on the `Checkout` screen that
/// summarizes the purpose of the screen. At the moment there are two
/// checkout screens.
final class CheckoutSummaryTableViewCell: UITableViewCell {
    
    // MARK: - Injected
    
    var content: LabelContent! {
        didSet {
            descriptionLabel.content = content
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private var descriptionLabel: UILabel!
}
