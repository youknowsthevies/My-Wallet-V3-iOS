//
//  PriceAlertTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 11/15/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// NOTE: There is currently a `UIButton` in `PriceAlertTableViewCell`.
/// In a future release this will be for toggling price alerts. Currently
/// the button is not visible.
final class PriceAlertTableViewCell: UITableViewCell {
    
    var currency: CryptoCurrency! {
        didSet {
            // swiftlint:disable line_length
            currentPriceLabel.text = "\(LocalizationConstants.DashboardDetails.current) \(currency.displayCode) \(LocalizationConstants.DashboardDetails.price)"
        }
    }
    
    @IBOutlet private var currentPriceLabel: UILabel!
}
