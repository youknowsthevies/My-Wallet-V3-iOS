//
//  BadgeImageView.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 3/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

public final class BadgeImageView: UIView {
    
    // MARK: - Private IBOutlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var containerView: UIView!
    
    // MARK: - Rx
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Public Properties
    
    public var viewModel: BadgeImageViewModel! {
        didSet {
            disposeBag = DisposeBag()
            
            // Set non-reactive properties
            layer.cornerRadius = viewModel.cornerRadius
            
            // Bind background color
            viewModel.backgroundColor
                .drive(containerView.rx.backgroundColor)
                .disposed(by: disposeBag)
            
            // bind label color
            viewModel.contentColor
                .drive(imageView.rx.tintColor)
                .disposed(by: disposeBag)
            
            // Bind image
            viewModel.image
                .drive(imageView.rx.image)
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
    }
    
}
