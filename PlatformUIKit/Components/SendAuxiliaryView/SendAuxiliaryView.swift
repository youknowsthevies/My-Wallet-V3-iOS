//
//  SendAuxiliaryView.swift
//  PlatformUIKit
//
//  Created by Daniel on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public final class SendAuxiliaryView: UIView {
    
    // MARK: - Properties
    
    public var presenter: SendAuxiliaryViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            maxButtonView.viewModel = presenter.maxButtonViewModel
            availableBalanceView.presenter = presenter.availableBalanceContentViewPresenter
            networkFeeView.presenter = presenter.networkFeeContentViewPresenter

            presenter
                .state
                .map(\.networkFeeVisibility)
                .drive(networkFeeView.rx.visibility)
                .disposed(by: disposeBag)
        }
    }
    
    private let availableBalanceView: ContentLabelView
    private let networkFeeView: ContentLabelView
    private let maxButtonView: ButtonView
    private var disposeBag = DisposeBag()
        
    public init() {
        availableBalanceView = ContentLabelView()
        networkFeeView = ContentLabelView()
        maxButtonView = ButtonView()
        
        super.init(frame: UIScreen.main.bounds)
        
        addSubview(availableBalanceView)
        addSubview(maxButtonView)
        addSubview(networkFeeView)
        
        availableBalanceView.layoutToSuperview(.centerY)
        availableBalanceView.layoutToSuperview(.leading, offset: Spacing.outer)
        
        networkFeeView.layoutToSuperview(.centerY)
        networkFeeView.layoutToSuperview(.trailing, offset: -Spacing.outer)
        
        maxButtonView.layoutToSuperview(.centerY)
        maxButtonView.layoutToSuperview(.trailing, offset: -Spacing.outer)
        maxButtonView.layout(dimension: .height, to: 30)
    }
    
    required init?(coder: NSCoder) { unimplemented() }
}
