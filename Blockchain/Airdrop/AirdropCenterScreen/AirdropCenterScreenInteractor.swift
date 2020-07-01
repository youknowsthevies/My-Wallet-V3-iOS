//
//  AirdropCenterScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 27/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

final class AirdropCenterScreenInteractor {
    
    // MARK: - Interactors
    
    var startedAirdropsInteractors: Observable<[AirdropTypeCellInteractor]> {
        startedAirdropsInteractorsRelay
            .asObservable()
            .distinctUntilChanged()
    }
    
    var endedAirdropsInteractors: Observable<[AirdropTypeCellInteractor]> {
        endedAirdropsInteractorsRelay
            .asObservable()
            .distinctUntilChanged()
    }
    
    private let startedAirdropsInteractorsRelay = BehaviorRelay<[AirdropTypeCellInteractor]>(value: [])
    private let endedAirdropsInteractorsRelay = BehaviorRelay<[AirdropTypeCellInteractor]>(value: [])
    
    // MARK: - Injected Services
    
    private let service: AirdropCenterServiceAPI
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    /// use `UserInformationServiceProvider` when merged into `dev`.
    init(service: AirdropCenterServiceAPI = AirdropCenterService.shared) {
        self.service = service
        
        let allCampaigns = service.campaignsCalculationState
            .compactMap { $0.value?.campaigns }
            .map { campaigns in
                 campaigns
                    .sorted { (lhs, rhs) -> Bool in
                        let lhsDate = lhs.dropDate ?? .distantFuture
                        let rhsDate = rhs.dropDate ?? .distantFuture
                        return lhsDate > rhsDate
                    }
            }
        
        allCampaigns
            .map { campaigns in
                campaigns.filter { $0.state == .started }
            }
            .map { campaigns in
                campaigns.map { AirdropTypeCellInteractor(campaign: $0) }
            }
            .bindAndCatch(to: startedAirdropsInteractorsRelay)
            .disposed(by: disposeBag)
        
        allCampaigns
            .map { campaigns in
                campaigns.filter { $0.state == .ended }
            }
            .map { campaigns in
                campaigns.map { AirdropTypeCellInteractor(campaign: $0) }
            }
            .bindAndCatch(to: endedAirdropsInteractorsRelay)
            .disposed(by: disposeBag)
    }
    
    func refresh() {
        service.refresh()
    }
}
