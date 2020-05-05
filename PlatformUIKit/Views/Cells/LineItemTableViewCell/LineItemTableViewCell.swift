//
//  LineItemTableViewCell.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

/// Has two labels, one which is a `title` and the other a `description`.
/// They are in a vertical stackView and appear as a list on `Checkout` screens.
public final class LineItemTableViewCell: UITableViewCell {

    // MARK: - Exposed Properites

    public var presenter: LineItemCellPresenting! {
        didSet {
            disposeBag = DisposeBag()
            guard let presenter = presenter else { return }
            presenter.titleLabelContentPresenter.state
                .compactMap { $0 }
                .bind(to: rx.titleContent)
                .disposed(by: disposeBag)

            presenter.descriptionLabelContentPresenter.state
                .compactMap { $0 }
                .bind(to: rx.descriptionContent)
                .disposed(by: disposeBag)

            presenter.backgroundColor
                .drive(rx.backgroundColor)
                .disposed(by: disposeBag)

            presenter.image
                .map { [weak self] in
                    $0 == nil ? 0 : self?.imageViewWidth
                }
                .drive(onNext: { [weak self] value in
                    self?.imageWidthConstraint.constant = value ?? 0
                })
                .disposed(by: disposeBag)

            presenter.image
                .drive(accessoryImageView.rx.image)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private let imageViewWidth: CGFloat = 22

    // MARK: - Private IBOutlets

    @IBOutlet private var accessoryImageView: UIImageView!
    @IBOutlet private var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet private var stackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var descriptionLabel: UILabel!
}

// MARK: - Rx

fileprivate extension Reactive where Base: LineItemTableViewCell {

    var titleContent: Binder<LabelContent.State.Presentation> {
        return Binder(base) { view, state in
            switch state {
            case .loading:
                break
            case .loaded(next: let value):
                view.titleLabel.content = value.labelContent
            }
        }
    }

    var descriptionContent: Binder<LabelContent.State.Presentation> {
        return Binder(base) { view, state in
            switch state {
            case .loading:
                break
            case .loaded(next: let value):
                view.descriptionLabel.content = value.labelContent
            }
        }
    }
}
