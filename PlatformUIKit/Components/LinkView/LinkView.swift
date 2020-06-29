//
//  LinkView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 28/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

/// A view model for `LinkView` that can display a link embedded in text,
/// levaraging `InteractableTextView` to do so.
public final class LinkView: UIView {
    
    // MARK: - Properties
    
    public var viewModel: LinkViewModel! {
        didSet {
            disposeBag = DisposeBag()
            guard let viewModel = viewModel else {
                return
            }
            textView.viewModel = viewModel.textViewModel
            viewModel.textDidChange
                .observeOn(MainScheduler.instance)
                .bindAndCatch(weak: textView) { (textView) in
                    self.textDidChange()
                }
                .disposed(by: disposeBag)
        }
    }
    
    private let textView = InteractableTextView()
            
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
        addSubview(textView)
        textView.fillSuperview()
    }
    
    private func textDidChange() {
        textView.setupHeight()
    }
}
