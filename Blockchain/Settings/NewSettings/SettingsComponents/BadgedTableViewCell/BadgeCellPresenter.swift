//
//  BadgeCellPresenter.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import PlatformUIKit
import RxCocoa

/// This is used on `BadgeTableViewCell`. There are many
/// types of `BadgeTableViewCell` (e.g. PIT connection status, KYC status, mobile
/// verification status, etc). Each of these cells need their own implementation of
/// `LabelContentPresenting` and `BadgeAssetPresenting`
protocol BadgeCellPresenting: SettingsAsyncPresenting {
    var labelContentPresenting: LabelContentPresenting { get }
    var badgeAssetPresenting: BadgeAssetPresenting { get }
}

/// A `BadgeCellPresenting` class for showing the user's mobile verification status
final class MobileVerificationCellPresenter: BadgeCellPresenting {
    
    // MARK: - Properties
    
    var isLoading: Bool {
        isLoadingRelay.value
    }
    
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    
    private let isLoadingRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(interactor: MobileVerificationBadgeInteractor) {
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.Badge.mobileNumber,
            descriptors: .settings
        )
        badgeAssetPresenting = MobileVerificationBadgePresenter(
            interactor: interactor
        )
        
        badgeAssetPresenting.state
            .map { $0.isLoading }
            .bind(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}

/// A `BadgeCellPresenting` class for showing the user's 2FA verification status
final class EmailVerificationCellPresenter: BadgeCellPresenting {
    
    // MARK: - Properties
    
    var isLoading: Bool {
        isLoadingRelay.value
    }
    
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    
    private let isLoadingRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()
    
    init(interactor: EmailVerificationBadgeInteractor) {
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.Badge.email,
            descriptors: .settings
        )
        badgeAssetPresenting = EmailVerificationBadgePresenter(
            interactor: interactor
        )
        
        badgeAssetPresenting.state
            .map { $0.isLoading }
            .bind(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}

/// A `BadgeCellPresenting` class for showing the user's preferred local currency
final class PreferredCurrencyCellPresenter: BadgeCellPresenting {
    
    // MARK: - Properties
    
    var isLoading: Bool {
        isLoadingRelay.value
    }
    
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    
    private let isLoadingRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(interactor: PreferredCurrencyBadgeInteractor) {
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.Badge.localCurrency,
            descriptors: .settings
        )
        badgeAssetPresenting = PreferredCurrencyBadgePresenter(
            interactor: interactor
        )
        
        badgeAssetPresenting.state
            .map { $0.isLoading }
            .bind(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}

/// A `BadgeCellPresenting` class for showing the user's Swap Limits
final class TierLimitsCellPresenter: BadgeCellPresenting {
    
    var isLoading: Bool {
        isLoadingRelay.value
    }
    
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    
    private let isLoadingRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()
    
    init(tiersProviding: TierLimitsProviding) {
        labelContentPresenting = TierLimitsLabelContentPresenter(provider: tiersProviding, descriptors: .settings)
        badgeAssetPresenting = TierLimitsBadgePresenter(provider: tiersProviding)
        
        badgeAssetPresenting.state
            .map { $0.isLoading }
            .bind(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}

/// A `BadgeCellPresenting` class for showing the user's PIT connection status
final class PITConnectionCellPresenter: BadgeCellPresenting {
    
    var isLoading: Bool {
        isLoadingRelay.value
    }
    
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    
    private let isLoadingRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()
    
    init(pitConnectionProvider: PITConnectionStatusProviding) {
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.Badge.blockchainExchange,
            descriptors: .settings
        )
        badgeAssetPresenting = PITConnectionBadgePresenter(provider: pitConnectionProvider)
        
        badgeAssetPresenting.state
            .map { $0.isLoading }
            .bind(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}

/// A `BadgeCellPresenting` class for showing the user's recovery phrase status
final class RecoveryStatusCellPresenter: BadgeCellPresenting {
    
    var isLoading: Bool {
        isLoadingRelay.value
    }
    
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    
    private let isLoadingRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()
    
    init(recoveryStatusProviding: RecoveryPhraseStatusProviding) {
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.Badge.recoveryPhrase,
            descriptors: .settings    
        )
        badgeAssetPresenting = RecoveryPhraseBadgePresenter(provider: recoveryStatusProviding)
        
        badgeAssetPresenting.state
            .map { $0.isLoading }
            .bind(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}
