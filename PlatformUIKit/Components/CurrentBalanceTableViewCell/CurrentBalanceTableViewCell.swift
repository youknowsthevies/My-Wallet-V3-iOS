//
//  CurrentBalanceTableViewCell.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxSwift

public final class CurrentBalanceTableViewCell: UITableViewCell {

    public var presenter: CurrentBalanceCellPresenting! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            assetBalanceView.presenter = presenter?.assetBalanceViewPresenter
            guard let presenter = presenter else {
                badgeImageView.viewModel = nil
                thumbSideImageView.set(nil)
                labelStackView.clear()
                return
            }

            presenter.badgeImageViewModel
                .drive(badgeImageView.rx.viewModel)
                .disposed(by: disposeBag)

            presenter.iconImageViewContent
                .drive(thumbSideImageView.rx.content)
                .disposed(by: disposeBag)

            presenter.title
                .map {
                    LabelContent(
                        text: $0,
                        font: .main(.semibold, 16.0),
                        color: .titleText,
                        alignment: .left,
                        accessibility: .id(presenter.titleAccessibilitySuffix)
                    )
                }
                .drive(labelStackView.topLabel.rx.content)
                .disposed(by: disposeBag)

            presenter.description
                .map {
                    LabelContent(
                        text: $0,
                        font: .main(.medium, 14.0),
                        color: .descriptionText,
                        alignment: .left,
                        accessibility: .id(presenter.descriptionAccessibilitySuffix)
                    )
                }
                .drive(labelStackView.middleLabel.rx.content)
                .disposed(by: disposeBag)

            presenter.pending
                .map {
                    LabelContent(
                        text: $0,
                        font: .main(.medium, 14.0),
                        color: .mutedText,
                        alignment: .left,
                        accessibility: .id(presenter.pendingAccessibilitySuffix)
                    )
                }
                .drive(labelStackView.bottomLabel.rx.content)
                .disposed(by: disposeBag)

            presenter.pendingLabelVisibility
                .map { $0.isHidden }
                .drive(labelStackView.bottomLabel.rx.isHidden)
                .disposed(by: disposeBag)

            presenter.separatorVisibility
                .map { $0.defaultAlpha }
                .drive(separatorView.rx.alpha)
                .disposed(by: disposeBag)

            presenter.separatorVisibility
                .map { $0.isHidden ? 0 : 1 }
                .drive(separatorHeightConstraint.rx.constant)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private var separatorHeightConstraint: NSLayoutConstraint!

    private let badgeImageView = BadgeImageView()
    private let thumbSideImageView = UIImageView()
    private let labelStackView = ThreeLabelStackView()
    private let assetBalanceView = AssetBalanceView()
    private let separatorView = UIView()

    // MARK: - Lifecycle

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }

    func setup() {
        contentView.addSubview(badgeImageView)
        contentView.addSubview(thumbSideImageView)
        contentView.addSubview(labelStackView)
        contentView.addSubview(assetBalanceView)
        contentView.addSubview(separatorView)

        separatorHeightConstraint = separatorView.layout(dimension: .height, to: 1)
        separatorView.layoutToSuperview(.leading, .trailing, .bottom)

        badgeImageView.layout(size: .edge(32))
        badgeImageView.layoutToSuperview(.leading, offset: 24)
        badgeImageView.layoutToSuperview(.centerY)

        thumbSideImageView.layout(size: .edge(16))
        thumbSideImageView.layout(to: .trailing, of: badgeImageView, offset: 4)
        thumbSideImageView.layout(to: .bottom, of: badgeImageView, offset: 4)

        labelStackView.layoutToSuperview(.top, offset: 16)
        labelStackView.layoutToSuperview(.bottom, offset: -16)
        labelStackView.layout(edge: .leading, to: .trailing, of: badgeImageView, offset: 16)

        assetBalanceView.layout(edge: .leading, to: .trailing, of: labelStackView)
        assetBalanceView.layoutToSuperview(.trailing, offset: -24)
        assetBalanceView.layoutToSuperview(.centerY)

        thumbSideImageView.image = UIImage(named: "icon_custody_lock",
                                           in: .platformUIKit,
                                           compatibleWith: nil)
        separatorView.backgroundColor = .lightBorder

        layoutIfNeeded()

        assetBalanceView.shimmer(
            estimatedFiatLabelSize: CGSize(width: 90, height: 16),
            estimatedCryptoLabelSize: CGSize(width: 100, height: 14)
        )
    }
}
