//
//  SendAuxililaryViewPresenter.swift
//  PlatformUIKit
//
//  Created by Daniel on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public final class SendAuxililaryViewPresenter: Equatable {
    
    // MARK: - Types
    
    private typealias LocalizationId = LocalizationConstants.Transaction.Send
    
    // MARK: - Public Properties
    
    public let availableBalanceContentViewPresenter: ContentLabelViewPresenter
    
    public let networkFeeContentViewPresenter: ContentLabelViewPresenter
    
    // MARK: - Internal Properties
    
    let maxButtonVisibility: Driver<Visibility>
    
    let networkFeeContentVisibility: Driver<Visibility>
    
    let maxButtonViewModel: ButtonViewModel
    
    // MARK: - Private
    
    /// NOTE: Private `Visibility` values allow
    /// `SendAuxililaryViewPresenter` to be `Equatable`. This is
    /// needed for the `EnterAmount` screen.
    private let maxButtonVisible: Visibility
    
    /// NOTE: Private `Visibility` values allow
    /// `SendAuxililaryViewPresenter` to be `Equatable`. This is
    /// needed for the `EnterAmount` screen.
    private let networkFeeContentVisible: Visibility
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    public init(interactor: SendAuxililaryViewInteractorAPI,
                availableBalanceTitle: String,
                maxButtonTitle: String,
                maxButtonVisibility: Visibility = .visible,
                networkFeeVisibility: Visibility = .hidden) {
        self.maxButtonVisible = maxButtonVisibility
        self.networkFeeContentVisible = networkFeeVisibility
        self.networkFeeContentVisibility = .just(networkFeeVisibility)
        self.maxButtonVisibility = .just(maxButtonVisibility)
        availableBalanceContentViewPresenter = ContentLabelViewPresenter(
                title: availableBalanceTitle,
                alignment: .left,
                interactor: interactor.availableBalanceContentViewInteractor
        )
        networkFeeContentViewPresenter = ContentLabelViewPresenter(
            title: LocalizationId.networkFee,
            alignment: .right,
            interactor: interactor.networkFeeContentViewInteractor
        )
        
        maxButtonViewModel = ButtonViewModel.secondary(
            with: maxButtonTitle,
            font: .main(.semibold, 14)
        )
        
        maxButtonViewModel.contentInsetRelay.accept(
            UIEdgeInsets(horizontal: Spacing.standard, vertical: 0)
        )
        
        maxButtonViewModel.tap
            .emit(to: interactor.resetToMaxAmountRelay)
            .disposed(by: disposeBag)
        
        availableBalanceContentViewPresenter.containsDescription
            .drive(maxButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
    }
}

public extension SendAuxililaryViewPresenter {
    static func ==(lhs: SendAuxililaryViewPresenter, rhs: SendAuxililaryViewPresenter) -> Bool {
        lhs.maxButtonVisible == rhs.maxButtonVisible &&
        lhs.networkFeeContentVisible == rhs.networkFeeContentVisible
    }
}
