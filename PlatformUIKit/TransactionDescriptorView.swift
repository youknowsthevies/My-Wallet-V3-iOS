//
//  TransactionDescriptorView.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 10/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

public final class TransactionDescriptorView: UIView {
    
    // MARK: - Injected
    
    public var viewModel: TransactionDescriptorViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            
            viewModel
                .fromAccountBadgeImageViewModel
                .drive(fromAccountBadgeImageView.rx.viewModel)
                .disposed(by: disposeBag)
            
            viewModel
                .toAccountBadgeImageViewModel
                .drive(fromAccountBadgeImageView.rx.viewModel)
                .disposed(by: disposeBag)
            
            viewModel
                .transactionTypeBadgeImageViewModel
                .drive(transactionTypeBadgeImageView.rx.viewModel)
                .disposed(by: disposeBag)
        }
    }
    
    fileprivate let fromAccountBadgeImageView = BadgeImageView()
    fileprivate let transactionTypeBadgeImageView = BadgeImageView()
    fileprivate let toAccountBadgeImageView = BadgeImageView()
    
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

    private func setup() {

        backgroundColor = .clear
        clipsToBounds = true

        addSubview(fromAccountBadgeImageView)
        addSubview(toAccountBadgeImageView)
        addSubview(transactionTypeBadgeImageView)
        bringSubviewToFront(transactionTypeBadgeImageView)

        fromAccountBadgeImageView.layoutToSuperview(.centerY, .leading, .top)
        fromAccountBadgeImageView.layout(
            edge: .trailing,
            to: .leading,
            of: toAccountBadgeImageView,
            offset: -16
        )
        toAccountBadgeImageView.layoutToSuperview(.centerY, .trailing, .top)
        transactionTypeBadgeImageView.layoutToSuperview(.centerY, .centerX)
        fromAccountBadgeImageView.layout(
            size: .init(edge: 32)
        )
        toAccountBadgeImageView.layout(
            size: .init(edge: 32)
        )
        transactionTypeBadgeImageView.layout(
            size: .init(edge: 24)
        )
    }
}

// MARK: - Rx

public extension Reactive where Base: TransactionDescriptorView {
    var viewModel: Binder<TransactionDescriptorViewModel> {
        Binder(base) { view, viewModel in
            view.viewModel = viewModel
        }
    }
}

