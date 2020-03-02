//
//  LabeledButtonView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import PlatformKit

final class LabeledButtonView<ViewModel: LabeledButtonViewModelAPI>: UIView {
        
    // MARK: - UI Properties
    
    private let button = UIButton()
    
    // MARK: - Injected
    
    var viewModel: ViewModel! {
        didSet {
            disposeBag = DisposeBag()
            guard let viewModel = viewModel else { return }
            
            backgroundColor = viewModel.backgroundColor
            
            button.rx.tap
                .bind(to: viewModel.tapRelay)
                .disposed(by: disposeBag)
            
            viewModel.content
                .drive(button.rx.content)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Accessors
    
    private var disposeBag = DisposeBag()

    // MARK: - Setup
    
    init() {
        super.init(frame: CGRect(origin: .zero, size: .init(width: 80, height: 40)))
        clipsToBounds = true
        layer.cornerRadius = 20
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        addSubview(button)
        button.layoutToSuperview(axis: .horizontal)
        button.layoutToSuperview(axis: .vertical)
        button.maximizeResistanceAndHuggingPriorities()
        button.contentEdgeInsets = .init(horizontal: 16, vertical: 12)
        button.addTargetForTouchDown(self, selector: #selector(touchDown))
        button.addTargetForTouchUp(self, selector: #selector(touchUp))
    }
    
    @objc
    private func touchDown() {
        alpha = 0.85
    }
    
    @objc
    private func touchUp() {
        alpha = 1
    }
}
