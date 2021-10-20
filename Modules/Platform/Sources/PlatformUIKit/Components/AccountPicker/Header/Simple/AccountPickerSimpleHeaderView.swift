// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

final class AccountPickerSimpleHeaderView: UIView, AccountPickerHeaderViewAPI {

    // MARK: Properties

    var model: AccountPickerSimpleHeaderModel! {
        didSet {
            subtitleLabel.content = model?.subtitleLabel ?? .empty
        }
    }

    // MARK: Properties - AccountPickerHeaderViewAPI

    var searchBar: UISearchBar? { nil }

    // MARK: Private Properties

    private let subtitleLabel = UILabel()
    private let separator = UIView()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: Private Methods

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
