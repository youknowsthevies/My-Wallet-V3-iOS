// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FeatureReferralDomain
import Foundation
import SwiftUI
import ToolKit
import UIComponentsKit

public final class ReferralAppObserver: Session.Observer {
    unowned let app: AppProtocol
    let referralService: ReferralServiceAPI
    let featureFlagService: FeatureFlagsServiceAPI
    let topViewController: TopMostViewControllerProviding

    private var cancellables: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        referralService: ReferralServiceAPI,
        featureFlagService: FeatureFlagsServiceAPI,
        topViewController: TopMostViewControllerProviding = DIKit.resolve()
    ) {
        self.app = app
        self.referralService = referralService
        self.featureFlagService = featureFlagService
        self.topViewController = topViewController
    }

    var observers: [BlockchainEventSubscription] {
        [
            walletCreated
        ]
    }

    public func start() {
        for observer in observers {
            observer.start()
        }
    }

    public func stop() {
        for observer in observers {
            observer.stop()
        }
    }

    private lazy var referralCodePublisher = app.publisher(
        for: blockchain.user.creation.referral.code,
        as: String.self
    )
    .compactMap(\.value)

    private lazy var featureFlagPublisher = featureFlagService
        .isEnabled(.referral)

    lazy var walletCreated = app.on(blockchain.user.wallet.created) { [weak self] _ in
        guard let self = self else { return }
        Publishers
            .CombineLatest(
                self.featureFlagPublisher,
                self.referralCodePublisher
            )
            .map { isEnabled, referralCode in
                guard isEnabled else { return }
                _ = self.referralService.createReferral(with: referralCode)
            }
            .sink(receiveValue: { _ in })
            .store(in: &self.cancellables)
    }

    private func fetchReferralCampaign() {
        referralService
            .fetchReferralCampaign()
            .sink(receiveValue: { [weak self] referral in
                guard let self = self,
                      let referral = referral else { return }
                self.presentReferralPopup(with: referral)
            })
            .store(in: &cancellables)
    }

    private func presentReferralPopup(with referral: Referral) {
        let popupView = ReferralPopup(store: .init(
            initialState: .init(referralInfo: referral),
            reducer: ReferFriendModule.reducer,
            environment: ReferFriendEnvironment(mainQueue: .main)
        ))
        topViewController.topMostViewController?.present(UIHostingController(rootView: popupView), animated: true)
    }
}
