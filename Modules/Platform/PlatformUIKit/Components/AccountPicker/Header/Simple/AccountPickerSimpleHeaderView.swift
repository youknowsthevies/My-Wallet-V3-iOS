//
//  AccountPickerSimpleHeaderView.swift
//  PlatformUIKit
//
//  Created by Paulo on 14/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class AccountPickerSimpleHeaderView: UIView {
    static let defaultHeight: CGFloat = 64
    private let subtitleLabel: UILabel = UILabel()
    private let separator: UIView = UIView()

    var model: AccountPickerSimpleHeaderModel! {
        didSet {
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
        addSubview(subtitleLabel)
        addSubview(separator)

        // MARK: Subtitle Label

        subtitleLabel.layoutToSuperview(.centerY)
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
