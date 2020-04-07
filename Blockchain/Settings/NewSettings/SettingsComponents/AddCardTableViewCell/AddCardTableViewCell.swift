//
//  AddCardTableViewCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 3/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class AddCardTableViewCell: UITableViewCell {
    
    // MARK: - Public Properites
    
    var presenter: AddCardCellPresenter! {
        didSet {
            guard let presenter = presenter else { return }
            badgeImageView.viewModel = presenter.badgeImageViewModel
            titleLabel.content = presenter.descriptionLabelContent
        }
    }
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var badgeImageView: BadgeImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .titleText
    }
}
