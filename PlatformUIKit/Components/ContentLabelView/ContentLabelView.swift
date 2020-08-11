//
//  ContentLabelView.swift
//  BuySellUIKit
//
//  Created by Daniel on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import ToolKit
import PlatformKit

public final class ContentLabelView: UIView {
    
    var presenter: ContentLabelViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            titleLabel.content = presenter?.titleLabelContent ?? .empty
            presenter?.descriptionLabelContent
                .drive(descriptionLabel.rx.content)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Properties
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    public init() {
        super.init(frame: UIScreen.main.bounds)
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        titleLabel.layoutToSuperview(.top, .leading, .trailing)
        descriptionLabel.layoutToSuperview(.bottom, .leading, .trailing)
        descriptionLabel.layout(edge: .top, to: .bottom, of: titleLabel, offset: Spacing.standard)
    }
    
    required init?(coder: NSCoder) { unimplemented() }
}
