//
//  BadgeCollectionTableViewCell.swift
//  PlatformUIKit
//
//  Created by Paulo on 07/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxSwift

public final class StackSpacerView: UIView { }

class BadgeCollectionTableViewCell: UITableViewCell {

    @IBOutlet private var stackView: UIStackView!

    private var disposeBag = DisposeBag()

    // MARK: - Public Properites

    public var presenters: [BadgeAssetPresenting] = [] {
        willSet {
            disposeBag = DisposeBag()
            stackView.removeSubviews()
        }
        didSet {
            presenters
                .forEach { add($0) }
            stackView.addArrangedSubview(StackSpacerView())
        }
    }

    private func add(_ presenter: BadgeAssetPresenting) {
        let badge = BadgeView()
        badge.contentHuggingPriority = (.required, .required)
        stackView.addArrangedSubview(badge)
        presenter.state
            .compactMap { $0 }
            .bind(to: badge.rx.viewModel)
            .disposed(by: disposeBag)
    }
}
