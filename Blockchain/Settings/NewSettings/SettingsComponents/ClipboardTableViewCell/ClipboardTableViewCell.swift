//
//  ClipboardTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

final class ClipboardTableViewCell: UITableViewCell {
    
    // MARK: - Model
    
    struct ViewModel {
        let title: String
        let accessibilityID: String?
        
        init(title: String, accessibilityID: String? = nil) {
            self.title = title
            self.accessibilityID = accessibilityID
        }
    }
    
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
