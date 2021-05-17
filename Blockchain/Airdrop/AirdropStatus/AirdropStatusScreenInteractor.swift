// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class AirdropStatusScreenInteractor {

    // MARK: - Exposed Properties

    /// Streams the calculation state of the campaign
    var calculationState: Observable<ValueCalculationState<AirdropCampaigns.Campaign>> {
        calculationStateRelay.asObservable()
    }

    // MARK: - Injected Properties

    private let service: AirdropCenterServiceAPI

    // MARK: - Rx Accessors

    private let calculationStateRelay = BehaviorRelay<ValueCalculationState<AirdropCampaigns.Campaign>>(value: .calculating)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(service: AirdropCenterServiceAPI = resolve(),
         campaignName: AirdropCampaigns.Campaign.Name) {
        self.service = service
        service.fetchCampaignCalculationState(campaignName: campaignName, useCache: true)
            .bindAndCatch(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
}
