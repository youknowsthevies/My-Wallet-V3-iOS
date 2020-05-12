//
//  LabelTableViewCell.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

public final class LabelTableViewCell: UITableViewCell {

    // MARK: - Exposed Properites

    public var content: LabelContent! {
        willSet {
            presenter = nil
        }
        didSet {
            guard content != nil else { return }
            titleLabel.content = content
        }
    }

    public var presenter: LabelContentPresenting! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard presenter != nil else { return }
            presenter.state
                .bind(to: rx.titleContent)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()

    // MARK: - IBOutlets
    
    @IBOutlet fileprivate var titleLabel: UILabel!

    public override func prepareForReuse() {
        super.prepareForReuse()
        content = .empty
    }
}

fileprivate extension Reactive where Base: LabelTableViewCell {

    var titleContent: Binder<LabelContent.State.Presentation> {
        Binder(base) { view, state in
            switch state {
            case .loading:
                break
            case .loaded(next: let value):
                view.titleLabel.content = value.labelContent
            }
        }
    }
}
