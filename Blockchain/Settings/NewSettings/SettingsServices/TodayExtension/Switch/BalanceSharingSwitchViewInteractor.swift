// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class BalanceSharingSwitchViewInteractor: SwitchViewInteracting {

    // MARK: - Types
    
    typealias InteractionState = LoadingState<SwitchInteractionAsset>
    
    // MARK: - Setup
    
    private lazy var setup: Void = {
        service.isEnabled
            .map { .loaded(next: .init(isOn: $0, isEnabled: true)) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
        
        switchTriggerRelay
            .flatMap(weak: self) { (self, value) -> Observable<Void> in
                self.service
                    .balanceSharing(enabled: value)
                    .andThen(Observable.just(()))
            }
            .subscribe()
            .disposed(by: disposeBag)
    }()
    
    // MARK: - Public Properties

    var state: Observable<InteractionState> {
        _ = setup
        return stateRelay
            .asObservable()
    }
    
    // MARK: - SwitchViewInteracting

    let switchTriggerRelay = PublishRelay<Bool>()
    
    // MARK: - Private Properties

    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    private let service: BalanceSharingSettingsServiceAPI

    init(service: BalanceSharingSettingsServiceAPI) {
        self.service = service
    }
}
