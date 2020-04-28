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
    let accessibilityID: String?
    
    init(title: String, accessibilityID: String? = nil) {
        self.title = title
        self.accessibilityID = accessibilityID
    }
}

final class PlainTableViewCell: UITableViewCell {
    
    // MARK: - Model
    
    typealias ViewModel = PlainCellViewModel
    
    var viewModel: ViewModel! {
        didSet {
            titleLabel.text = viewModel.title
            titleLabel.accessibilityIdentifier = viewModel.accessibilityID
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
