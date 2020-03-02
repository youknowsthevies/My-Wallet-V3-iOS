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
        didSet {
            disposeBag = DisposeBag()
            guard let viewModel = viewModel else {
                return
            }
                        
            viewModel.leadingImage
                .drive(leadingImageView.rx.content)
                .disposed(by: disposeBag)
            
            viewModel.title
                .drive(titleLabel.rx.content)
                .disposed(by: disposeBag)
                        
            viewModel.disclosureImageViewContent
                .drive(disclosureImageView.rx.content)
                .disposed(by: disposeBag)
            
            button.rx.tap
                .bind(to: viewModel.tapRelay)
                .disposed(by: disposeBag)
            
            viewModel.accessibility
                .drive(button.rx.accessibility)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - UI Properties
    
    private let leadingImageView = UIImageView()
    private let titleLabel = UILabel()
    private let disclosureImageView = UIImageView()
    private let button = UIButton()
    
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
    
    private func setup() {
        
        // General setup
        
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 8
        layer.borderColor = UIColor.lightBorder.cgColor
        layer.borderWidth = 1
        
        // Subviews hierarchy setup
        
        addSubview(leadingImageView)
        addSubview(titleLabel)
        addSubview(disclosureImageView)
        addSubview(button)
        
        // Layout the view leading to trailing
        
        button.fillSuperview()
        button.addTargetForTouchDown(self, selector: #selector(touchDown))
        button.addTargetForTouchUp(self, selector: #selector(touchUp))

        leadingImageView.layoutToSuperview(.leading, offset: 24)
        leadingImageView.layoutToSuperview(.centerY)
        leadingImageView.layout(size: .init(edge: 24))
        
        titleLabel.layout(edge: .leading, to: .trailing, of: leadingImageView, offset: 16)
        titleLabel.layoutToSuperview(.centerY)
        titleLabel.layout(edge: .trailing, to: .leading, of: disclosureImageView, offset: -20)
        
        disclosureImageView.layoutToSuperview(.trailing, offset: -14)
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
