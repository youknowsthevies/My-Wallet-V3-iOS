//
//  CustodyWithdrawalScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxCocoa
import ToolKit

final class CustodyWithdrawalScreenPresenter {
    
    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizationID = LocalizationConstants.SimpleBuy.Withdrawal
    
    // MARK: - Navigation Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        if #available(iOS 13.0, *) {
            return .content(.init(title: nil, image: #imageLiteral(resourceName: "cancel_icon").withTintColor(.red), accessibility: nil))
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
        return .text(value: "\(LocalizationID.title) \(currency.name) \(LocalizationConstants.wallet)")
    }
    
    var barStyle: Screen.Style.Bar {
        if #available(iOS 13.0, *) {
            return .darkContent(ignoresStatusBar: false, background: .white)
        } else {
            return .lightContent(ignoresStatusBar: false, background: .navigationBarBackground)
        }
    }
    
    var activityIndicatorVisibility: Driver<Visibility> {
        return activityIndicatorVisibilityRelay.asDriver()
    }
    
    var balanceViewVisibility: Driver<Visibility> {
        return balanceViewVisibilityRelay.asDriver()
    }
    
    let descriptionLabel: LabelContent
    let sendButtonViewModel: ButtonViewModel
    let assetBalanceViewPresenter: AssetBalanceViewPresenter
    
    // MARK: - Private Properties
    
    private let analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording
    private let activityIndicatorVisibilityRelay = BehaviorRelay<Visibility>(value: .visible)
    private let balanceViewVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let interactor: CustodyWithdrawalScreenInteractor
    private let currency: CryptoCurrency
    private let loadingPresenter: LoadingViewPresenting
    private unowned let stateService: CustodyWithdrawalStateServiceAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(interactor: CustodyWithdrawalScreenInteractor,
         currency: CryptoCurrency,
         stateService: CustodyWithdrawalStateServiceAPI,
         loadingPresenter: LoadingViewPresenting = LoadingViewPresenter.shared,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared) {
        self.analyticsRecorder = analyticsRecorder
        self.loadingPresenter = loadingPresenter
        self.interactor = interactor
        self.currency = currency
        self.stateService = stateService
        
        self.descriptionLabel = .init(
            text: String(format: LocalizationConstants.SimpleBuy.Withdrawal.description, currency.code),
            font: .mainMedium(12.0),
            color: .descriptionText,
            alignment: .center,
            accessibility: .none
        )
        
        self.assetBalanceViewPresenter = AssetBalanceViewPresenter(
            alignment: .center,
            interactor: interactor.assetBalanceInteractor,
            descriptors: .init(fiatFont: .mainMedium(48.0),
                               fiatTextColor: .textFieldText,
                               cryptoFont: .mainMedium(14.0),
                               cryptoTextColor: .textFieldText)
        )
        
        self.sendButtonViewModel = .primary(with: LocalizationID.action)
        
        let stateObservable = interactor.state
        
        stateObservable
            .map { $0 == .settingUp ? .visible : .hidden }
            .bind(to: activityIndicatorVisibilityRelay)
            .disposed(by: disposeBag)
        
        stateObservable
            .map { $0 != .settingUp ? .visible : .hidden }
            .bind(to: balanceViewVisibilityRelay)
            .disposed(by: disposeBag)
        
        stateObservable
            .map { $0.isReady }
            .bind(to: self.sendButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        stateObservable
            .map { $0.isSubmitting }
            .bind(weak: self, onNext: { (self, value) in
                switch value {
                case true:
                    self.loadingPresenter.show(with: .circle, text: nil)
                case false:
                    self.loadingPresenter.hide()
                }
            })
            .disposed(by: disposeBag)
        
        stateObservable
            .filter { $0 == .submitted || $0 == .error }
            .do(onNext: { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .submitted:
                    self.analyticsRecorder.record(event: AnalyticsEvent.sbWithdrawalScreenSuccess)
                case .error:
                    self.analyticsRecorder.record(event: AnalyticsEvent.sbWithdrawalScreenFailure)
                case .loaded, .settingUp, .submitting:
                    break
                }
            })
            .map { value -> CustodyWithdrawalStatus in
                switch value {
                case .submitted:
                    return .successful
                case .error:
                    return .failed
                case .loaded, .settingUp, .submitting:
                    return .unknown
                }
            }
            .bind(to: self.stateService.completionRelay)
            .disposed(by: disposeBag)
        
        self.sendButtonViewModel
            .tapRelay
            .bind(weak: self) { (self) in
                self.analyticsRecorder.record(
                    event: AnalyticsEvent.sbWithdrawalScreenClicked(asset: self.currency)
                )
                interactor.withdrawalRelay.accept(())
            }
            .disposed(by: disposeBag)
    }
    
    func viewDidLoad() {
        analyticsRecorder.record(event: AnalyticsEvent.sbWithdrawalScreenShown(asset: currency))
    }
    
    func navigationBarTrailingButtonTapped() {
        stateService.previousRelay.accept(())
    }
    
    func navigationBarLeadingButtonTapped() {
        stateService.previousRelay.accept(())
    }
}
