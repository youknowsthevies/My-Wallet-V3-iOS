//
//  SeparatorTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 1/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

/// The `Checkout` screens show a line separator with eight points of verical
/// padding on either side. This separator only appears above the first and below
/// the last `LineItemTableViewCell`
final class SeparatorTableViewCell: UITableViewCell {
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var lineView: UIView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lineView.backgroundColor = .mediumBackground
    }
}
