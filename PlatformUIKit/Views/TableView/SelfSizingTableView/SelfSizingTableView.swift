//
//  SelfSizingTableView.swift
//  PlatformUIKit
//
//  Created by AlexM on 11/25/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Simple `UITableView` that sizes itself. Handy for if your
/// `UITableView` is in a containerView or a `UIStackView`.
public final class SelfSizingTableView: UITableView {

    static private let maxHeight = UIScreen.main.bounds.size.height

    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupContentSize()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContentSize()
    }

    private let _contentSizeDisposeBag = DisposeBag()

    private func setupContentSize() {
        rx
            .observe(type(of: contentSize), "contentSize")
            .distinctUntilChanged()
            .subscribe { [weak self] event in
                switch event {
                case .completed,
                     .error:
                    break
                case .next:
                    self?.invalidateIntrinsicContentSize()
                }
            }
            .disposed(by: _contentSizeDisposeBag)
    }

    override public var intrinsicContentSize: CGSize {
        return CGSize(
            width: contentSize.width,
            height: min(contentSize.height, SelfSizingTableView.maxHeight)
        )
    }
}
