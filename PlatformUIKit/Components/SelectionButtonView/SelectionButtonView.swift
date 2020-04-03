//
//  SelectionButtonView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

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
                    case .image(let content):
                        self.leadingImageView.set(content)
                        self.leadingLabel.content = .empty
                    case .label(let content):
                        self.leadingLabel.content = content
                        self.leadingImageView.set(.empty)
                    case .none:
                        self.leadingLabel.content = .empty
                        self.leadingImageView.set(.empty)
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

            viewModel.disclosureImageViewContent
                .drive(disclosureImageView.rx.content)
                .disposed(by: disposeBag)

            button.rx
                .controlEvent(.touchUpInside)
                .bind(to: viewModel.tapRelay)
                .disposed(by: disposeBag)

            viewModel.accessibility
                .drive(button.rx.accessibility)
                .disposed(by: disposeBag)

            viewModel.shouldShowSeparator
                .map { !$0 }
                .drive(separatorView.rx.isHidden)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - UI Properties

    private let leadingImageView = UIImageView()
    private let leadingLabel = UILabel()
    private let separatorView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let disclosureImageView = UIImageView()
    private let button = UIControl()
    private var titleLabelBottomToCenterY: NSLayoutConstraint!
    private var titleLabelCenterYToCenterY: NSLayoutConstraint!

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
        subtitleLabel.isHidden = !shouldDisplay
        titleLabelBottomToCenterY.isActive = shouldDisplay
        titleLabelCenterYToCenterY.isActive = !shouldDisplay
        setNeedsLayout()
    }

    private func setup() {

        // General setup

        backgroundColor = .white
        clipsToBounds = true
        separatorView.backgroundColor = .lightBorder

        // Subviews hierarchy setup

        addSubview(leadingImageView)
        addSubview(leadingLabel)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(disclosureImageView)
        addSubview(button)
        addSubview(separatorView)

        // Layout the view leading to trailing

        separatorView.layout(edges: .leading, .trailing, .bottom, to: self)
        separatorView.layout(dimension: .height, to: 1)

        button.fillSuperview()
        button.addTargetForTouchDown(self, selector: #selector(touchDown))
        button.addTargetForTouchUp(self, selector: #selector(touchUp))

        leadingImageView.layoutToSuperview(.leading, offset: 24)
        leadingImageView.layoutToSuperview(.centerY)
        leadingImageView.layout(size: .init(edge: 32))

        leadingLabel.layout(to: .centerX, of: leadingImageView)
        leadingLabel.layout(to: .centerY, of: leadingImageView)

        titleLabel.layout(edge: .leading, to: .trailing, of: leadingImageView, offset: 16)
        titleLabelBottomToCenterY = titleLabel.layout(edge: .bottom, to: .centerY, of: self, offset: -3)
        titleLabelCenterYToCenterY = titleLabel.layout(edge: .centerY, to: .centerY, of: self, activate: false)
        titleLabel.layout(edge: .trailing, to: .leading, of: disclosureImageView, offset: -8)

        subtitleLabel.layout(edge: .leading, to: .trailing, of: leadingImageView, offset: 16)
        subtitleLabel.layout(edge: .top, to: .centerY, of: self, offset: 3)
        subtitleLabel.layout(edge: .trailing, to: .leading, of: disclosureImageView, offset: -8)

        disclosureImageView.layoutToSuperview(.trailing, offset: -30)
        disclosureImageView.layoutToSuperview(.centerY)
        disclosureImageView.maximizeResistanceAndHuggingPriorities()
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
