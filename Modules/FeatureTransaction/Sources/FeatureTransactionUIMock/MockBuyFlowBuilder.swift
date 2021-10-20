// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureTransactionUI
import PlatformKit
import RIBs
import UIKit

public final class MockBuyFlowRouter: RIBs.Router<BuyFlowInteractor>, BuyFlowRouting {

    public struct RecordedInvocations {
        public var start: [(cryptoAccount: CryptoAccount?, presenter: UIViewController)] = []
    }

    public private(set) var recordedInvocations = RecordedInvocations()

    public func start(with cryptoAccount: CryptoAccount?, from presenter: UIViewController) {
        recordedInvocations.start.append((cryptoAccount, presenter))
    }
}

public final class MockBuyFlowBuilder: BuyFlowBuildable {

    public private(set) var builtRouters: [MockBuyFlowRouter] = []

    public func build(with listener: BuyFlowListening, interactor: BuyFlowInteractor) -> BuyFlowRouting {
        let router = MockBuyFlowRouter(interactor: interactor)
        builtRouters.append(router)
        return router
    }
}
