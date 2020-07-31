//
//  LinkedBankView.swift
//  BuySellUIKit
//
//  Created by Daniel on 16/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class LinkedBankView: UIView {
        
    var viewModel: LinkedBankViewModel! {
        didSet {
            nameLabel.content = viewModel?.nameLabelContent ?? .empty
            limitsLabel.content = viewModel?.limitLabelContent ?? .empty
            accountLabel.content = viewModel?.accountLabelContent ?? .empty
            badgeImageView.viewModel = viewModel?.badgeImageViewModel
        }
    }
    
    // MARK: - Private IBOutlets
    
    private let stackView = UIStackView()
    private let nameLabel = UILabel()
    private let limitsLabel = UILabel()
    private let accountLabel = UILabel()
    private let badgeImageView = BadgeImageView()

    // MARK: - Setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = Spacing.interItem
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(limitsLabel)
        
        addSubview(stackView)
        addSubview(badgeImageView)
        addSubview(accountLabel)
        
        badgeImageView.layoutToSuperview(.centerY)
        badgeImageView.layout(size: CGSize(width: 32, height: 20))
        badgeImageView.layoutToSuperview(.leading, offset: Spacing.outer)

        accountLabel.layoutToSuperview(.centerY)
        accountLabel.layout(edge: .leading, to: .trailing, of: stackView, offset: Spacing.inner)
        accountLabel.layoutToSuperview(.trailing, offset: -Spacing.outer)
        accountLabel.horizontalContentHuggingPriority = .required
        accountLabel.horizontalContentCompressionResistancePriority = .required
        
        stackView.layout(edge: .leading, to: .trailing, of: badgeImageView, offset: Spacing.inner)
        stackView.layoutToSuperview(.centerY)
        stackView.layoutToSuperview(axis: .vertical, offset: 16, priority: .defaultHigh)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}

