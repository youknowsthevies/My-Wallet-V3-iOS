//
//  CustodyWithdrawalSummaryPresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxCocoa
import RxRelay

/// The status of the withdrawal after submission
enum CustodyWithdrawalStatus {
    /// Default state
    case unknown
    
    /// The withdrawal was successful
    case successful
    
    /// The withdrawal failed
    case failed
}

final class CustodyWithdrawalSummaryPresenter {
    
    typealias Status = CustodyWithdrawalStatus
    
    // MARK: - Localization
    
    typealias LocalizationSuccessIDs = LocalizationConstants.SimpleBuy.Withdrawal.SummarySuccess
    typealias LocalizationFailureIDs = LocalizationConstants.SimpleBuy.Withdrawal.SummaryFailure
    
    // MARK: - Navigation Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        if #available(iOS 13.0, *) {
            return .content(.init(title: nil, image: #imageLiteral(resourceName: "cancel_icon"), accessibility: nil))
        } else {
            return .none
        }
    }
    
    var leadingButton: Screen.Style.LeadingButton {
        if #available(iOS 13.0, *) {
            return .none
        } else {
            return .close
        }
    }
    
    var titleView: Screen.Style.TitleView {
        return .text(value: "\(LocalizationConstants.SimpleBuy.Withdrawal.title) \(currency.name) \(LocalizationConstants.wallet)")
    }
    
    var barStyle: Screen.Style.Bar {
        if #available(iOS 13.0, *) {
            return .darkContent(ignoresStatusBar: false, background: .white)
        } else {
            return .lightContent(ignoresStatusBar: false, background: .navigationBarBackground)
        }
    }
    
    // MARK: - Public Properties
    
    let actionViewModel: ButtonViewModel
    
    var imageDriver: Driver<UIImage> {
        imageRelay.asDriver()
    }
    
    var titleLabelDriver: Driver<LabelContent> {
        titleLabelRelay.asDriver()
    }
    
    var descriptionLabelDriver: Driver<LabelContent> {
        descriptionLabelRelay.asDriver()
    }
    
    // MARK: - Private Properties
    
    private let currency: CryptoCurrency
    private let imageRelay = BehaviorRelay<UIImage>(value: #imageLiteral(resourceName: "success_icon"))
    private let titleLabelRelay = BehaviorRelay<LabelContent>(value: .empty)
    private let descriptionLabelRelay = BehaviorRelay<LabelContent>(value: .empty)
    private unowned let stateService: CustodyWithdrawalStateServiceAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(status: Status, currency: CryptoCurrency, stateService: CustodyWithdrawalStateServiceAPI) {
        self.currency = currency
        self.stateService = stateService
        
        switch status {
        case .unknown:
            fatalError("This state should never occur")
        case .failed:
            let title: LabelContent = .init(
                text: LocalizationFailureIDs.title,
                font: .main(.semibold, 20.0),
                color: .textFieldText,
                alignment: .center,
                accessibility: .none
            )
            let description: LabelContent = .init(
                text: LocalizationFailureIDs.description,
                font: .main(.medium, 14.0),
                color: .textFieldText,
                alignment: .center,
                accessibility: .none
            )
            
            actionViewModel = .primary(with: LocalizationFailureIDs.action)
            
            titleLabelRelay.accept(title)
            descriptionLabelRelay.accept(description)
            imageRelay.accept(#imageLiteral(resourceName: "Icon-Close-Circle-Red"))
        case .successful:
            let title: LabelContent = .init(
                text: "\(LocalizationSuccessIDs.title) \(currency.displayCode) \(LocalizationSuccessIDs.sent).",
                font: .main(.semibold, 20.0),
                color: .textFieldText,
                alignment: .center,
                accessibility: .none
            )
            
            let description: LabelContent = .init(
                text: LocalizationSuccessIDs.description,
                font: .main(.medium, 14.0),
                color: .textFieldText,
                alignment: .center,
                accessibility: .none
            )
            
            actionViewModel = .primary(with: LocalizationSuccessIDs.action)
            
            imageRelay.accept(#imageLiteral(resourceName: "success_icon"))
            titleLabelRelay.accept(title)
            descriptionLabelRelay.accept(description)
        }
        
        actionViewModel.tapRelay
            .bind(weak: self) { (self) in
                self.stateService.nextRelay.accept(())
            }
            .disposed(by: disposeBag)
    }
    
    func navigationBarTrailingButtonTapped() {
        stateService.nextRelay.accept(())
    }
    
    func navigationBarLeadingButtonTapped() {
        stateService.previousRelay.accept(())
    }
}
