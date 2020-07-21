//
//  BadgeNumberedItemView.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 6/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public final class BadgeNumberedItemView: UIView {
    
    // MARK: - Injected
    
    public var viewModel: BadgeNumberedItemViewModel! {
        didSet {
            badgeView.viewModel = viewModel.badgeViewModel
            titleLabel.content = viewModel.titleLabelContent
            descriptionLabel.content = viewModel.descriptionLabelContent
        }
    }
    
    
    // MARK: - Private Properties
    
    fileprivate let badgeView = BadgeView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(badgeView)
        addSubview(stackView)
        
        badgeView.layout(size: .init(edge: Sizing.badge))
        badgeView.layoutToSuperview(.leading, .top)
        
        stackView.axis = .vertical
        stackView.spacing = 4.0
        stackView.layout(edge: .leading, to: .trailing, of: badgeView, offset: Spacing.inner)
        stackView.layoutToSuperview(.top, .bottom, .trailing)
        titleLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0
        for view in [titleLabel, descriptionLabel] {
            stackView.addArrangedSubview(view)
        }
    }
}
