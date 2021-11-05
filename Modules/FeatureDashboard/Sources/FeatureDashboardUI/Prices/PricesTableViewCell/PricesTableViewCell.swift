// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class PricesTableViewCell: UITableViewCell {

    // MARK: Types

    private enum Design {
        static let separatorHeight: CGFloat = 1
        static let badgeImageEdge: CGFloat = 32
        static let badgeImageMargin: CGFloat = 24
        static let textToBadgeImage: CGFloat = 16
        static let textToAccessory: CGFloat = 8
        static let textOffCenter: CGFloat = 2
    }

    // MARK: Properties

    var presenter: PricesTableViewCellPresenter? {
        willSet {
            disposeBag = .init()
        }
        didSet {
            badgeImageView.viewModel = presenter?.imageViewModel
            titleLabel.content = presenter?.titleLabelContent ?? .empty
            presenter?
                .subtitleLabelContent
                .drive(subtitleLabel.rx.attributedText)
                .disposed(by: disposeBag)
        }
    }

    // MARK: Private Properties

    private let badgeImageView = BadgeImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let separatorView = UIView()
    private var disposeBag: DisposeBag = .init()

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: Private Methods

    private func setup() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        separatorView.backgroundColor = .lightBorder
        contentView.addSubview(badgeImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        addSubview(separatorView)

        separatorView.layoutToSuperview(axis: .horizontal)
        separatorView.layoutToSuperview(.bottom)
        separatorView.layout(dimension: .height, to: Design.separatorHeight)

        badgeImageView.layout(size: .edge(Design.badgeImageEdge))
        badgeImageView.layoutToSuperview(axis: .vertical, offset: Design.badgeImageMargin)
        badgeImageView.layoutToSuperview(.leading, offset: Design.badgeImageMargin)

        titleLabel.layout(edge: .leading, to: .trailing, of: badgeImageView, offset: Design.textToBadgeImage)
        titleLabel.layoutToSuperview(.trailing, offset: -Design.textToAccessory)
        titleLabel.layout(edge: .bottom, to: .centerY, of: contentView, offset: -Design.textOffCenter)

        subtitleLabel.layout(edge: .leading, to: .trailing, of: badgeImageView, offset: Design.textToBadgeImage)
        subtitleLabel.layoutToSuperview(.trailing, offset: -Design.textToAccessory)
        subtitleLabel.layout(edge: .top, to: .centerY, of: contentView, offset: Design.textOffCenter)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}
