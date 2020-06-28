//
//  MultiBadgeTableViewCell.swift
//  PlatformUIKit
//
//  Created by Paulo on 07/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxSwift

public final class StackSpacerView: UIView { }

class MultiBadgeTableViewCell: UITableViewCell {

    // MARK: Private Properties

    private let stackView: UIStackView = .init()

    private var disposeBag: DisposeBag = .init()

    private var horizontalConstraints: Axis.Constraints?
    private var verticalConstraints: Axis.Constraints?

    // MARK: - Public Properites

    public var model: MultiBadgeCellModel! {
        willSet {
            disposeBag = DisposeBag()
            stackView.removeSubviews()
        }
        didSet {
            guard let model = model else { return }
            model
                .badges
                .drive(onNext: { [weak self] models in
                    self?.stackView.removeSubviews()
                    models.forEach { self?.add($0) }
                    self?.stackView.addArrangedSubview(StackSpacerView())
                })
                .disposed(by: disposeBag)

            model
                .layoutMargins
                .drive(onNext: { [weak self] layoutMargins in
                    self?.horizontalConstraints?.leading.constant = layoutMargins.left
                    self?.horizontalConstraints?.trailing.constant = -layoutMargins.right
                    self?.verticalConstraints?.leading.constant = layoutMargins.top
                    self?.verticalConstraints?.trailing.constant = -layoutMargins.bottom
                })
                .disposed(by: disposeBag)
        }
    }

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: Private Methods

    private func add(_ presenter: BadgeAssetPresenting) {
        let badge = BadgeView()
        badge.contentHuggingPriority = (.defaultHigh, .defaultHigh)
        badge.layout(dimension: .height, to: 32)
        stackView.addArrangedSubview(badge)
        presenter.state
            .compactMap { $0 }
            .bindAndCatch(to: badge.rx.viewModel)
            .disposed(by: disposeBag)
    }

    private func setup() {
        selectionStyle = .none
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        contentView.addSubview(stackView)
        horizontalConstraints = stackView.layoutToSuperview(axis: .horizontal)
        stackView.layout(dimension: .height, to: 32)
        verticalConstraints = stackView.layoutToSuperview(axis: .vertical)
    }
}

