// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import OpenBanking
import PlatformKit
import SwiftUI
import ToolKit
import UIComponentsKit

public enum OpenBankingEvent {
    case linked(OpenBanking.BankAccount)
    case authorised(OpenBanking.BankAccount, payment: OpenBanking.Payment.Details)
    case failed(OpenBanking.Error)
}

public final class OpenBankingViewController: UIHostingController<OpenBankingView> {

    public var event$: AnyPublisher<OpenBankingEvent, Never> {
        rootView.environment.event$.eraseToAnyPublisher()
    }

    public convenience init(
        pay amountMinor: String,
        product: String,
        from account: OpenBanking.BankAccount,
        environment: OpenBankingEnvironment
    ) {
        self.init(.pay(amountMinor: amountMinor, product: product, from: account), environment: environment)
    }

    public convenience init(environment: OpenBankingEnvironment) {
        self.init(.linkBankAccount, environment: environment)
    }

    required init(_ state: OpenBankingState, environment: OpenBankingEnvironment) {
        super.init(rootView: OpenBankingView(state: state, environment: environment))
    }

    @objc dynamic required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }
}
