//
//  MobileVerificationCellPresenter.swift
//  Blockchain
//
//  Created by Paulo on 06/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxRelay
import RxSwift

/// A `BadgeCellPresenting` class for showing the user's mobile verification status
final class MobileVerificationCellPresenter: BadgeCellPresenting {

    // MARK: - Properties

    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    var isLoading: Bool {
        isLoadingRelay.value
    }

    // MARK: - Private Properties

    private let isLoadingRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(interactor: MobileVerificationBadgeInteractor) {
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.Badge.mobileNumber,
            descriptors: .settings
        )
        badgeAssetPresenting = DefaultBadgeAssetPresenter(
            interactor: interactor
        )

        badgeAssetPresenting.state
            .map { $0.isLoading }
            .bind(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}
