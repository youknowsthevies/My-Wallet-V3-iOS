//
//  AnnouncementTableViewCell.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class AnnouncementTableViewCell: UITableViewCell {

    // MARK: - Lifecycle

    /// Set custom spacing
    var bottomSpacing: CGFloat {
        set {
            bottomSpacingConstraint.constant = -newValue
        }
        get {
            -bottomSpacingConstraint.constant
        }
    }
    
    private var bottomSpacingConstraint: NSLayoutConstraint!
    
    /// A view that represents the announcement
    private var cardView: AnnouncementCardViewConforming!
    
    var viewModel: AnnouncementCardViewModel! {
        didSet {
            guard let viewModel = viewModel else { return }
            switch viewModel.presentation {
            case .regular:
                cardView = AnnouncementCardView(using: viewModel)
            case .mini:
                cardView = AnnouncementMiniCardView(using: viewModel)
            }
            contentView.addSubview(cardView)
            cardView.layoutToSuperview(.top, .leading, .trailing)
            bottomSpacingConstraint = cardView.layoutToSuperview(.bottom)
        }
    }
        
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cardView.removeFromSuperview()
        cardView = nil
        viewModel = nil
    }
}
