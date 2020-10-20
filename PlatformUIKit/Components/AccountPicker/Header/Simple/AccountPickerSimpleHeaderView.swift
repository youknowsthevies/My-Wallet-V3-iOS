//
//  AccountPickerSimpleHeaderView.swift
//  PlatformUIKit
//
//  Created by Paulo on 14/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class AccountPickerSimpleHeaderView: UIView {
    static let defaultHeight: CGFloat = 120
    private let titleLabel: UILabel = UILabel()
    private let subtitleLabel: UILabel = UILabel()
    private let separator: UIView = UIView()

    var model: AccountPickerSimpleHeaderModel! {
        didSet {
            titleLabel.content = model?.titleLabel ?? .empty
            subtitleLabel.content = model?.subtitleLabel ?? .empty
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(separator)

        // MARK: Title Label

        titleLabel.layoutToSuperview(.top, offset: 24)
        titleLabel.layoutToSuperview(axis: .horizontal, offset: 24)

        // MARK: Subtitle Label

        subtitleLabel.layoutToSuperview(.top, offset: 72)
        subtitleLabel.layoutToSuperview(axis: .horizontal, offset: 24)

        // MARK: Separator

        separator.backgroundColor = .lightBorder
        separator.layout(dimension: .height, to: 1)
        separator.layoutToSuperview(.leading, .trailing, .bottom)

        // MARK: Setup

        clipsToBounds = true
        subtitleLabel.numberOfLines = 0
    }

}
