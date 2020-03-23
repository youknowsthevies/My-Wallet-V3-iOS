//
//  UpdateMobileSubmissionInteractor.swift
//  Blockchain
//
//  Created by AlexM on 2/21/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

final class UpdateMobileSubmissionInteractor {
    
    typealias BadgeItem = BadgeAsset.Value.Interaction.BadgeItem
    
    struct InteractionModel {
        let badgeItem: BadgeItem
        let mobileNumber: String
        
        init(badgeItem: BadgeItem, mobileNumber: String = "") {
            self.badgeItem = badgeItem
            self.mobileNumber = mobileNumber
        }
    }
    
    typealias InteractionState = LoadingState<InteractionModel>
    
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    init(service: SettingsServiceAPI) {
        service
            .valueObservable
            .map {
                .init(
                    badgeItem: $0.isSMSVerified ? .verified : .unverified,
                    mobileNumber: $0.smsNumber ?? ""
                )
            }
            .map { .loaded(next: $0) }
            .startWith(.loading)
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

