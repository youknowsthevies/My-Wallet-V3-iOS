// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureOpenBankingDomain
import SwiftUI
import ToolKit
import UIComponentsKit

public final class OpenBankingViewController: UIHostingController<OpenBankingView> {

    public var eventPublisher: AnyPublisher<Result<Void, OpenBanking.Error>, Never> {
        rootView.environment.eventPublisher.eraseToAnyPublisher()
    }

    public convenience init(
        order: OpenBanking.Order,
        from account: OpenBanking.BankAccount,
        environment: OpenBankingEnvironment
    ) {
        self.init(
            .confirm(
                order: order,
                from: account
            ),
            environment: environment
        )
    }

    public convenience init(
        deposit amountMinor: String,
        product: String,
        from account: OpenBanking.BankAccount,
        environment: OpenBankingEnvironment
    ) {
        self.init(
            .deposit(
                amountMinor: amountMinor,
                product: product,
                from: account
            ),
            environment: environment
        )
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
