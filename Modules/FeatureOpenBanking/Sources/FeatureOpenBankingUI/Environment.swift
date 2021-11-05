// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineSchedulers
import DIKit
import FeatureOpenBankingDomain
import NetworkKit
import SwiftUI
import ToolKit

public struct OpenBankingEnvironment {

    public var environment: Self { self }
    public private(set) var eventPublisher = PassthroughSubject<Result<Void, OpenBanking.Error>, Never>()

    public var scheduler: Scheduler
    public var openBanking: OpenBanking
    public var showTransferDetails: () -> Void
    public var dismiss: () -> Void
    public var cancel: () -> Void
    public var openURL: URLOpener
    public var fiatCurrencyFormatter: FiatCurrencyFormatter

    public init(
        scheduler: Scheduler = .init(),
        openBanking: OpenBanking = resolve(),
        showTransferDetails: @escaping () -> Void = {},
        dismiss: @escaping () -> Void = {},
        cancel: @escaping () -> Void = {},
        openURL: URLOpener = resolve(),
        fiatCurrencyFormatter: FiatCurrencyFormatter = resolve(),
        currency: String
    ) {
        self.scheduler = scheduler
        self.openBanking = openBanking
        self.showTransferDetails = showTransferDetails
        self.dismiss = dismiss
        self.cancel = cancel
        self.openURL = openURL
        self.fiatCurrencyFormatter = fiatCurrencyFormatter

        openBanking.state.set(.currency, to: currency)
    }
}

extension OpenBankingEnvironment {

    public struct Scheduler {

        public var main: AnySchedulerOf<DispatchQueue>

        public init(main: AnySchedulerOf<DispatchQueue> = .main) {
            self.main = main
        }
    }
}
