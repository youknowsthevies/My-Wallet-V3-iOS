//
//  ContentLabelView.swift
//  BuySellUIKit
//
//  Created by Daniel on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public final class ContentLabelView: UIView {
    
    var presenter: ContentLabelViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter = presenter else { return }
            titleLabel.content = presenter.titleLabelContent
            presenter.descriptionLabelContent
                .drive(descriptionLabel.rx.content)
                .disposed(by: disposeBag)
            
            button.rx.tap
                .throttle(
                    .milliseconds(200),
                    latest: false,
                    scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
                )
                .observeOn(MainScheduler.instance)
                .bindAndCatch(to: presenter.tapRelay)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Properties
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let button = UIButton()
    private var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    public init() {
        super.init(frame: UIScreen.main.bounds)
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(button)
        
        titleLabel.layoutToSuperview(.top, .leading, .trailing)
        descriptionLabel.layoutToSuperview(.bottom, .leading, .trailing)
        descriptionLabel.layout(edge: .top, to: .bottom, of: titleLabel, offset: Spacing.standard)
        button.fillSuperview()
    }
    
    required init?(coder: NSCoder) { unimplemented() }
}
