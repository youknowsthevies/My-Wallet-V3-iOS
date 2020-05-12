//
//  ButtonView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 25/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/// The standard wallet button.
/// Typically located at the bottom of a context, used as primary / secondary CTA buttons.
/// - see also: [ButtonViewModel](x-source-tag://ButtonViewModel).
final public class ButtonView: UIView {
    
    // MARK: - UI Properties
    
    @IBOutlet private var button: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var label: UILabel!
    
    // Constraints for scenario with title only, and no image
    @IBOutlet private var labelToImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var labelToSuperviewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var labelToSuperviewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var labelToSuperviewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var labelToSuperviewTrailingConstraint: NSLayoutConstraint!

    // MARK: - Rx
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Dependencies
    
    public var viewModel: ButtonViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            
            // Set non-reactive properties
            layer.cornerRadius = viewModel.cornerRadius
            label.font = viewModel.font
            
            // Set accessibility
            accessibility = viewModel.accessibility
            
            // Bind background color
            viewModel.backgroundColor
                .drive(rx.backgroundColor)
                .disposed(by: disposeBag)
            
            // Bind border color
            viewModel.borderColor
                .drive(layer.rx.borderColor)
                .disposed(by: disposeBag)
            
            // bind label color
            viewModel.contentColor
                .drive(label.rx.textColor)
                .disposed(by: disposeBag)
            
            // Bind label text color
            viewModel.text
                .drive(label.rx.text)
                .disposed(by: disposeBag)
            
            // Bind image view tint color
            viewModel.contentColor
                .drive(imageView.rx.tintColor)
                .disposed(by: disposeBag)
            
            // Bind image view's image
            viewModel.image
                .drive(imageView.rx.image)
                .disposed(by: disposeBag)

            // Bind view model enabled indication to button
            viewModel.isEnabled
                .drive(button.rx.isEnabled)
                .disposed(by: disposeBag)
            
            // Bind opacity
            viewModel.alpha
                .drive(rx.alpha)
                .disposed(by: disposeBag)
            
            // bind contains image
            viewModel.containsImage
                .bind { [weak self] containsImage in
                    guard let self = self else { return }
                    if containsImage {
                        self.label.textAlignment = .natural
                        self.labelToImageViewLeadingConstraint.priority = .penultimateHigh
                        self.labelToSuperviewLeadingConstraint.priority = .penultimateLow
                    } else {
                        self.label.textAlignment = .center
                        self.labelToImageViewLeadingConstraint.priority = .penultimateLow
                        self.labelToSuperviewLeadingConstraint.priority = .penultimateHigh
                    }
                    self.layoutIfNeeded()
                }
                .disposed(by: disposeBag)
            
            // Bind button taps
            button.rx.tap
                .throttle(
                    .milliseconds(200),
                    latest: false,
                    scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
                )
                .observeOn(MainScheduler.instance)
                .bind(to: viewModel.tapRelay)
                .disposed(by: disposeBag)

            viewModel.contentInset
                .drive(onNext: { [weak self] contentInset in
                    self?.updateContentInset(to: contentInset)
                })
                .disposed(by: disposeBag)
        }
    }

    private func updateContentInset(to contentInset: UIEdgeInsets) {
        labelToSuperviewLeadingConstraint.constant = contentInset.left
        labelToSuperviewBottomConstraint.constant = contentInset.bottom
        labelToSuperviewTopConstraint.constant = contentInset.top
        labelToSuperviewTrailingConstraint.constant = contentInset.right
        layoutIfNeeded()
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
        layer.borderWidth = 1
    }
    
    // MARK: - User Interactions
    
    @IBAction private func touchUp() {
        alpha = 1
    }
    
    @IBAction private func touchDown() {
        alpha = 0.85
    }
}
