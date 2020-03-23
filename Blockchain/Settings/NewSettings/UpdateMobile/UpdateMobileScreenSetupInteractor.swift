//
//  UpdateMobileScreenSetupInteractor.swift
//  Blockchain
//
//  Created by AlexM on 2/21/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

final class UpdateMobileScreenSetupInteractor {
    
    typealias BadgeItem = BadgeAsset.Value.Interaction.BadgeItem
    
    struct InteractionModel {
        let badgeItem: BadgeItem
        let isSMSVerified: Bool
        let mobileNumber: String?
        
        init(badgeItem: BadgeItem, isSMSVerified: Bool, mobileNumber: String? = nil) {
            self.badgeItem = badgeItem
            self.isSMSVerified = isSMSVerified
            self.mobileNumber = mobileNumber
        }
    }
    
    typealias InteractionState = LoadingState<InteractionModel>
    
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    let setupTrigger = PublishRelay<Void>()
    
    // MARK: - Private Accessors
    
    private let serviceAPI: SettingsServiceAPI
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    init(service: SettingsServiceAPI) {
        self.serviceAPI = service
        setupTrigger
            .bind(weak: self) { (self) in
                self.setup()
            }
            .disposed(by: disposeBag)
        setupTrigger.accept(())
    }
    
    private func setup() {
        serviceAPI
            .valueObservable
            .map {
                .init(
                    badgeItem: $0.isSMSVerified ? .verified : .unverified,
                    isSMSVerified: $0.isSMSVerified,
                    mobileNumber: $0.smsNumber ?? ""
                )
            }
            .map { .loaded(next: $0) }
            .startWith(.loading)
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

