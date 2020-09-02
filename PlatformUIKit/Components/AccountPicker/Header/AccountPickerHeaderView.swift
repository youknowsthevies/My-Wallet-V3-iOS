//
//  AccountPickerHeaderView.swift
//  PlatformUIKit
//
//  Created by Paulo on 28/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

final class AccountPickerHeaderView: UIView {
    private let patternImageView: UIImageView = UIImageView()
    private let assetImageView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private let subtitleLabel: UILabel = UILabel()
    private let selectWalletLabel: UILabel = UILabel()
    private let separator: UIView = UIView()
    private let fadeMask = CAGradientLayer()
    
    var model: AccountPickerHeaderModel! {
        didSet {
            assetImageView.image = model?.image
            titleLabel.content = model?.titleLabel ?? .empty
            subtitleLabel.content = model?.subtitleLabel ?? .empty
            selectWalletLabel.content = model?.selectWalletLabel ?? .empty
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

        addSubview(patternImageView)
        addSubview(assetImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(selectWalletLabel)
        addSubview(separator)

        // MARK: Background Image Vie

        patternImageView.layoutToSuperview(.leading, .trailing, .top, .bottom)
        patternImageView.image = UIImage(named: "link-pattern", in: .platformUIKit, compatibleWith: nil)
        patternImageView.contentMode = .scaleAspectFill
        
        // MARK: Asset Image View

        assetImageView.layout(size: .edge(32))
        assetImageView.layoutToSuperview(.top, .leading, offset: 24)
        assetImageView.contentMode = .scaleAspectFit

        // MARK: Title Label

        titleLabel.layoutToSuperview(.top, offset: 74)
        titleLabel.layoutToSuperview(axis: .horizontal, offset: 24)

        // MARK: Subtitle Label

        subtitleLabel.layout(edge: .top, to: .bottom, of: titleLabel)
        subtitleLabel.layoutToSuperview(axis: .horizontal, offset: 24)

        // MARK: Select a Wallet Label

        selectWalletLabel.layoutToSuperview(.leading, offset: 24)
        selectWalletLabel.layoutToSuperview(.bottom, offset: -4)

        // MARK: Separator

        separator.backgroundColor = .lightBorder
        separator.layout(dimension: .height, to: 1)
        separator.layout(edge: .leading, to: .trailing, of: selectWalletLabel, offset: 8)
        separator.layoutToSuperview(.trailing)
        separator.layout(edge: .bottom, to: .lastBaseline, of: selectWalletLabel)

        // MARK: Fading Mask

        fadeMask.colors = [
            UIColor.black.cgColor,
            UIColor.black.withAlphaComponent(0.2).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor
        ]
        fadeMask.locations = [0, 0.7, 1]
        fadeMask.frame = bounds
        patternImageView.layer.mask = fadeMask

        // MARK: Setup

        clipsToBounds = true
        model = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fadeMask.frame = patternImageView.bounds
    }
}
