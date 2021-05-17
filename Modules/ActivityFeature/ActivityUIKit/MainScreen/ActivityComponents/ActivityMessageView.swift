// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

final class ActivityMessageView: UIView {

    var viewModel: ActivityMessageViewModel! {
        didSet {
            qrImageView.image = viewModel.image
            titleLabel.content = viewModel.titleLabelContent
            descriptionLabel.content = viewModel.descriptionLabelContent
            cryptoValueLabel.content = viewModel.cryptoAmountLabelContent
            sharedWithLabel.content = viewModel.sharedWithLabelContent
            badgeImageView.viewModel = viewModel.badgeImageViewModel
        }
    }

    // MARK: - Private Properties (UIStackView)

    private let sharedWithStackView = UIStackView()
    private let summaryStackView = UIStackView()
    private let descriptorsStackView = UIStackView()
    private let outerStackView = UIStackView()
    private let stackView = UIStackView()

    private let containerView = UIView()
    private let badgeImageView = BadgeImageView()
    private let imageContainerView = UIView()

    // MARK: - Private Properties (UIImageView)

    private let qrImageView = UIImageView()
    private let logoImageView = UIImageView()

    // MARK: - Private Properties (UILabel)

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let cryptoValueLabel = UILabel()
    private let sharedWithLabel = UILabel()

    // MARK: - Setup

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = .lightGray
        containerView.backgroundColor = .white
        addSubview(containerView)

        containerView.addSubview(sharedWithStackView)
        containerView.addSubview(logoImageView)
        containerView.addSubview(stackView)

        containerView.layer.shadowColor = UIColor.securePinGrey.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: Spacing.standard)
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 8.0
        containerView.layer.cornerRadius = 16.0
        containerView.clipsToBounds = false

        containerView.layoutToSuperview(axis: .horizontal, offset: Spacing.inner)
        containerView.layoutToSuperview(axis: .vertical, offset: Spacing.inner)

        summaryStackView.alignment = .leading
        summaryStackView.spacing = Spacing.inner
        stackView.axis = .vertical
        stackView.alignment = .center
        descriptorsStackView.axis = .vertical
        descriptorsStackView.alignment = .leading
        outerStackView.axis = .vertical
        outerStackView.alignment = .leading

        descriptorsStackView.addArrangedSubview(titleLabel)
        descriptorsStackView.addArrangedSubview(descriptionLabel)
        descriptorsStackView.addArrangedSubview(cryptoValueLabel)

        summaryStackView.addArrangedSubview(badgeImageView)
        summaryStackView.addArrangedSubview(descriptorsStackView)

        stackView.addArrangedSubview(summaryStackView)
        stackView.addArrangedSubview(imageContainerView)
        imageContainerView.addSubview(qrImageView)
        qrImageView.contentMode = .scaleAspectFit
        qrImageView.layout(edges: .top, .leading, to: imageContainerView, offset: 8.0)
        qrImageView.layout(edges: .bottom, .trailing, to: imageContainerView, offset: -8.0)

        sharedWithStackView.axis = .horizontal
        sharedWithStackView.addArrangedSubview(sharedWithLabel)
        sharedWithStackView.addArrangedSubview(logoImageView)

        logoImageView.image = UIImage(named: "logo_small")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.layout(size: .init(edge: 16.0))

        sharedWithStackView.alignment = .trailing
        sharedWithStackView.spacing = Spacing.standard / 2.0
        sharedWithStackView.layout(edges: .leading, to: containerView, offset: Spacing.standard, priority: .defaultLow)
        sharedWithStackView.layout(edges: .bottom, .trailing, to: containerView, offset: -Spacing.standard)

        badgeImageView.layout(size: .init(edge: Sizing.badge))

        summaryStackView.layout(edges: .top, .leading, to: containerView, offset: Spacing.standard)
        summaryStackView.layout(edges: .trailing, to: containerView, offset: -Spacing.standard)
        stackView.layout(edges: .trailing, to: containerView, offset: -Spacing.standard)
        stackView.layout(edge: .top, to: .bottom, of: sharedWithStackView, offset: Spacing.standard, priority: .defaultLow)
        imageContainerView.layer.shadowColor = UIColor.securePinGrey.cgColor
        imageContainerView.layer.shadowOffset = CGSize(width: 0, height: Spacing.standard)
        imageContainerView.layer.shadowOpacity = 0.5
        imageContainerView.layer.shadowRadius = 8.0
        imageContainerView.clipsToBounds = false
    }
}
