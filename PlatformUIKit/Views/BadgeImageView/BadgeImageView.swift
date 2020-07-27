//
//  BadgeImageView.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 3/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

public final class BadgeImageView: UIView {
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var containerView: UIView!
    
    @IBOutlet private var leadingOffsetConstraint: NSLayoutConstraint!
    @IBOutlet private var trailingOffsetConstraint: NSLayoutConstraint!
    
    @IBOutlet private var topOffsetConstraint: NSLayoutConstraint!
    @IBOutlet private var bottomOffsetConstraint: NSLayoutConstraint!

    private var sizeConstraints: LayoutForm.Constraints!
    
    // MARK: - Rx
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Public Properties
    
    public var viewModel: BadgeImageViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            
            // Bind corner radius
            viewModel.cornerRadius
                .drive(onNext: { [weak self] radius in
                    self?.setNeedsLayout()
                })
                .disposed(by: disposeBag)
            
            // Bind background color
            viewModel.backgroundColor
                .drive(containerView.rx.backgroundColor)
                .disposed(by: disposeBag)
            
            // Bind image
            viewModel.imageContent
                .drive(imageView.rx.content)
                .disposed(by: disposeBag)
            
            // Bind size if necessary
            viewModel.sizingType
                .drive(
                    onNext: { [weak self] type in
                        guard let self = self else { return }
                        switch type {
                        case .configuredByOwner:
                            self.sizeConstraints.set(priority: .penultimateLow)
                        case .constant(let size):
                            self.sizeConstraints.setConstant(
                                horizontal: size.width,
                                vertical: size.height
                            )
                            self.sizeConstraints.set(priority: .penultimateHigh)
                        }
                    }
                )
                .disposed(by: disposeBag)
            
            viewModel.marginOffset
                .drive(onNext: { [weak self] offset in
                    guard let self = self else { return }
                    self.leadingOffsetConstraint.constant = offset
                    self.trailingOffsetConstraint.constant = offset
                    self.topOffsetConstraint.constant = offset
                    self.bottomOffsetConstraint.constant = offset
                    self.layoutIfNeeded()
                })
                .disposed(by: disposeBag)
        }
    }
    
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
        fromNib()
        clipsToBounds = true
        
        sizeConstraints = layout(size: .init(edge: 32), priority: .penultimateLow)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard let viewModel = viewModel else { return }
        switch viewModel.cornerRadiusRelay.value {
        case .round:
            layer.cornerRadius = bounds.width * 0.5
        case .value(let value):
            layer.cornerRadius = value
        }
    }
}

// MARK: - Rx

public extension Reactive where Base: BadgeImageView {
    var viewModel: Binder<BadgeImageViewModel> {
        Binder(base) { view, viewModel in
            view.viewModel = viewModel
        }
    }
}

