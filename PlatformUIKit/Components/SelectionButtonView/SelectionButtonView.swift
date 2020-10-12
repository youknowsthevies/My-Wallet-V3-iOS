//
//  SelectionButtonView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxRelay
import RxSwift

public final class SelectionButtonView: UIView {

    // MARK: - Injected

    /// Injected in a manner that would enable `SelectionButtonView` to
    /// be a part of a queue mechanism.
    public var viewModel: SelectionButtonViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let viewModel = viewModel else {
                return
            }

            viewModel.leadingContent
                .drive(onNext: { [weak self] content in
                    guard let self = self else { return }
                    switch content {
                    case .badgeImage(let viewModel):
                        self.leadingBadgeImageView.viewModel = viewModel
                        self.leadingLabel.content = .empty
                        self.stackViewToLabelConstraint.priority = .defaultLow
                        self.stackViewToImageConstraint.priority = .penultimateHigh
                    case .label(let content):
                        self.leadingLabel.content = content
                        self.leadingBadgeImageView.viewModel = .empty
                        self.stackViewToLabelConstraint.priority = .penultimateHigh
                        self.stackViewToImageConstraint.priority = .defaultLow
                    case .none:
                        self.leadingLabel.content = .empty
                        self.leadingBadgeImageView.viewModel = .empty
                    }
                })
                .disposed(by: disposeBag)

            viewModel.title
                .drive(titleLabel.rx.content)
                .disposed(by: disposeBag)

            viewModel.subtitle
                .map { $0 ?? .empty }
                .drive(subtitleLabel.rx.content)
                .disposed(by: disposeBag)

            viewModel.subtitle
                .map { $0 != nil }
                .distinctUntilChanged()
                .drive(onNext: { [weak self] shouldDisplay in
                    self?.relayoutToDisplaySubtitle(shouldDisplay: shouldDisplay)
                })
                .disposed(by: disposeBag)

            viewModel.trailingContent
                .compactMap { $0.image }
                .drive(trailingImageView.rx.content)
                .disposed(by: disposeBag)

            viewModel.horizontalOffset
                .drive(onNext: { [weak self] offset in
                    self?.leadingConstraint.constant = offset
                    self?.trailingConstraint.constant = -offset
                })
                .disposed(by: disposeBag)
            
            viewModel.verticalOffset
                .drive(onNext: { [weak self] offset in
                    self?.verticalConstraints.set(offset: offset)
                })
                .disposed(by: disposeBag)
            
            viewModel.isButtonEnabled
                .drive(button.rx.isEnabled)
                .disposed(by: disposeBag)
            
            button.rx
                .controlEvent(.touchUpInside)
                .bindAndCatch(to: viewModel.tapRelay)
                .disposed(by: disposeBag)
            
            viewModel.trailingContentRelay
                .compactMap { $0.transaction }
                .bindAndCatch(to: transactionDescriptorView.rx.viewModel)
                .disposed(by: disposeBag)
            
            viewModel.trailingContentRelay
                .map { $0.transaction == nil }
                .map { $0 ? .hidden : .visible }
                .bindAndCatch(to: transactionDescriptorView.rx.visibility)
                .disposed(by: disposeBag)
            
            viewModel.accessibility
                .drive(button.rx.accessibility)
                .disposed(by: disposeBag)

            viewModel.shouldShowSeparator
                .map { !$0 }
                .drive(separatorView.rx.isHidden)
                .disposed(by: disposeBag)
            
            viewModel.leadingImageViewSize
                .drive(onNext: { [weak self] size in
                    self?.badgeImageViewSizeConstraints.setConstant(
                        horizontal: size.width,
                        vertical: size.height
                    )
                })
                .disposed(by: disposeBag)
        }
    }

    // MARK: - UI Properties

    private let transactionDescriptorView = TransactionDescriptorView()
    private let leadingBadgeImageView = BadgeImageView()
    private let leadingLabel = UILabel()
    private let separatorView = UIView()
    private let labelsStackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let trailingImageView = UIImageView()
    private let button = UIButton()

    private var leadingConstraint: NSLayoutConstraint!
    private var stackViewToImageConstraint: NSLayoutConstraint!
    private var stackViewToLabelConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var verticalConstraints: Axis.Constraints!
    
    private var badgeImageViewSizeConstraints: LayoutForm.Constraints!
    
    // MARK: - Accessors

    private var disposeBag = DisposeBag()

    // MARK: - Setup

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func relayoutToDisplaySubtitle(shouldDisplay: Bool) {
        if shouldDisplay {
            labelsStackView.addArrangedSubview(subtitleLabel)
        } else {
            labelsStackView.removeArrangedSubview(subtitleLabel)
        }
    }

    private func setup() {

        // General setup

        backgroundColor = .white
        clipsToBounds = true
        separatorView.backgroundColor = .lightBorder

        // Subviews hierarchy setup

        addSubview(leadingBadgeImageView)
        addSubview(leadingLabel)
        addSubview(labelsStackView)
        addSubview(trailingImageView)
        addSubview(transactionDescriptorView)
        addSubview(button)
        labelsStackView.addArrangedSubview(titleLabel)
        addSubview(separatorView)

        labelsStackView.distribution = .fillProportionally
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 6
        
        // Layout the view leading to trailing

        separatorView.layout(edges: .leading, .trailing, .bottom, to: self)
        separatorView.layout(dimension: .height, to: 1)

        button.fillSuperview()
        button.addTargetForTouchDown(self, selector: #selector(touchDown))
        button.addTargetForTouchUp(self, selector: #selector(touchUp))

        leadingBadgeImageView.layoutToSuperview(.centerY)
        badgeImageViewSizeConstraints = leadingBadgeImageView.layout(
            size: .init(edge: 32),
            priority: .penultimateHigh
        )
        leadingConstraint = leadingBadgeImageView.layoutToSuperview(.leading, offset: 24)
        
        leadingLabel.layout(to: .leading, of: leadingBadgeImageView)
        leadingLabel.layout(to: .centerY, of: leadingBadgeImageView)
        
        leadingLabel.horizontalContentHuggingPriority = .required
        
        verticalConstraints = labelsStackView.layoutToSuperview(axis: .vertical)
        stackViewToImageConstraint = labelsStackView.layout(
            edge: .leading,
            to: .trailing,
            of: leadingBadgeImageView,
            offset: 16,
            priority: .penultimateHigh
        )
        stackViewToLabelConstraint = labelsStackView.layout(
            edge: .leading,
            to: .trailing,
            of: leadingLabel,
            offset: 16,
            priority: .defaultLow
        )
        labelsStackView.layout(edge: .trailing, to: .leading, of: trailingImageView, offset: -8)

        titleLabel.verticalContentHuggingPriority = .required
        titleLabel.verticalContentCompressionResistancePriority = .required
        
        subtitleLabel.verticalContentHuggingPriority = .required
        subtitleLabel.verticalContentCompressionResistancePriority = .required
        
        trailingConstraint = trailingImageView.layoutToSuperview(.trailing, offset: -24)
        trailingImageView.layoutToSuperview(.centerY)
        trailingImageView.maximizeResistanceAndHuggingPriorities()
        
        transactionDescriptorView.layoutToSuperview(.trailing, offset: -24)
        transactionDescriptorView.layoutToSuperview(.centerY)
        transactionDescriptorView.maximizeResistanceAndHuggingPriorities()
    }

    @objc
    private func touchDown() {
        backgroundColor = .hightlightedBackground
    }

    @objc
    private func touchUp() {
        backgroundColor = .white
    }
}
