//
//  PlainTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 12/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

struct PlainCellViewModel {
    let title: String
    let accessibilityID: String
    let titleAccessibilityID: String
    
    init(title: String,
         accessibilityID: String,
         titleAccessibilityID: String) {
        self.title = title
        self.accessibilityID = accessibilityID
        self.titleAccessibilityID = titleAccessibilityID
    }
}

final class PlainTableViewCell: UITableViewCell {
    
    // MARK: - Model
    
    typealias ViewModel = PlainCellViewModel
    
    var viewModel: ViewModel! {
        didSet {
            titleLabel.text = viewModel.title
            titleLabel.accessibilityIdentifier = viewModel.titleAccessibilityID
            accessibility = .id(viewModel.accessibilityID)
        }
    }
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .titleText
    }
}
