// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

protocol AirdropCenterServiceAPI: AnyObject {

    var campaignsCalculationState: Observable<ValueCalculationState<AirdropCampaigns>> { get }

    /// An `Observable` that streams the airdrop campaigns
    func fetchCampaignsCalculationState(useCache: Bool) -> Observable<ValueCalculationState<AirdropCampaigns>>

    /// An `Observable` that streams an airdrop campaign by name
    func fetchCampaignCalculationState(
        campaignName: AirdropCampaigns.Campaign.Name,
        useCache: Bool
    ) -> Observable<ValueCalculationState<AirdropCampaigns.Campaign>>

    /// Triggers a refresh on the service
    func refresh()
}

// TODO: Move into `PlatformKit` when IOS-2724 is merged
final class AirdropCenterService: AirdropCenterServiceAPI {

    var campaignsCalculationState: Observable<ValueCalculationState<AirdropCampaigns>> {
        campaignsCalculationStateRelay.asObservable()
    }

    private let campaignsCalculationStateRelay = BehaviorRelay<ValueCalculationState<AirdropCampaigns>>(value: .invalid(.empty))
    private let fetchTriggerRelay = PublishRelay<Void>()

    private let disposeBag = DisposeBag()

    // MARK: - Injected (Privately used)

    private let client: AirdropCenterClientAPI

    // MARK: - Setup

    init(client: AirdropCenterClientAPI = resolve()) {
        self.client = client

        fetchTriggerRelay
            .throttle(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest(weak: self) { (self, _) -> Observable<AirdropCampaigns> in
                self.client.campaigns.asObservable()
            }
            .map { .value($0) }
            .catchErrorJustReturn(.invalid(.valueCouldNotBeCalculated))
            .bindAndCatch(to: campaignsCalculationStateRelay)
            .disposed(by: disposeBag)
    }

    /// Refreshes the campaigns
    func refresh() {
        fetchTriggerRelay.accept(())
    }

    func fetchCampaignsCalculationState(useCache: Bool) -> Observable<ValueCalculationState<AirdropCampaigns>> {
        campaignsCalculationState
            .do(onSubscribed: { [weak self] in
                guard let self = self else { return }
                if self.campaignsCalculationStateRelay.value.isInvalid || !useCache {
                    self.refresh()
                }
            })
    }

    func fetchCampaignCalculationState(
        campaignName: AirdropCampaigns.Campaign.Name,
        useCache: Bool
    ) -> Observable<ValueCalculationState<AirdropCampaigns.Campaign>> {
        fetchCampaignsCalculationState(useCache: useCache)
            .map { state in
                switch state {
                case .value(let campaigns):
                    if let campaign = campaigns.campaign(by: campaignName) {
                        return .value(campaign)
                    } else {
                        return .invalid(.valueCouldNotBeCalculated)
                    }
                case .invalid(.empty):
                    return .invalid(.empty)
                case .calculating:
                    return .calculating
                case .invalid:
                    return .invalid(.valueCouldNotBeCalculated)
                }
            }
    }
}
