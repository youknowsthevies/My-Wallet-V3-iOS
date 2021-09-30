// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

protocol AccountAuxiliaryViewInteractorAPI {
    /// The view has been tapped.
    /// This should trigger an event that presents
    /// a new screen to select a different account.
    var auxiliaryViewTappedRelay: PublishRelay<Void> { get }
}

extension AccountAuxiliaryViewInteractorAPI {
    /// Streams auxiliary view tap events.
    var auxiliaryViewTapped: Observable<Void> {
        auxiliaryViewTappedRelay
            .asObservable()
    }
}

private typealias LocalizationIds = LocalizationConstants.Transaction

final class AccountAuxiliaryViewInteractor: AccountAuxiliaryViewInteractorAPI {

    // MARK: - State

    struct State {
        let title: String
        let subtitle: String
        let imageResource: ImageResource
        let isEnabled: Bool

        init(
            title: String,
            subtitle: String,
            imageResource: ImageResource,
            isEnabled: Bool = true
        ) {
            self.title = title
            self.subtitle = subtitle
            self.imageResource = imageResource
            self.isEnabled = isEnabled
        }

        static let empty: State = .init(
            title: "",
            subtitle: "",
            imageResource: .local(
                name: "icon-bank",
                bundle: .platformUIKit
            ),
            isEnabled: false
        )
    }

    // MARK: - AccountAuxiliaryViewInteractorAPI

    let auxiliaryViewTappedRelay = PublishRelay<Void>()

    // MARK: Public Properties

    var state: Driver<State> {
        stateRelay
            .asDriver()
    }

    let stateRelay = BehaviorRelay<State>(value: .empty)

    // MARK: - Connect API

    func connect(stream: Observable<BlockchainAccount>) -> Disposable {
        stream
            .map { account -> State in
                switch account {
                case let bank as LinkedBankAccount:
                    let type = bank.accountType.title
                    let description = type + (type.isEmpty ? "" : " ") + "\(LocalizationIds.account) -"
                    let subtitle = description + " \(bank.accountNumber)"
                    return .init(
                        title: bank.label,
                        subtitle: subtitle,
                        imageResource: bank.logoResource
                    )

                case let linkablePayment as FeatureTransactionDomain.PaymentMethodAccount:
                    return .init(
                        title: linkablePayment.label,
                        subtitle: linkablePayment.paymentMethod.max.displayString,
                        imageResource: linkablePayment.logoResource
                    )
                case let fiatAccount as FiatAccount:
                    return .init(
                        title: fiatAccount.label,
                        subtitle: "",
                        imageResource: fiatAccount.logoResource
                    )
                default:
                    unimplemented()
                }
            }
            .bindAndCatch(to: stateRelay)
    }
}
