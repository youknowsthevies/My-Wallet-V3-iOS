// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
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

final class AccountAuxiliaryViewInteractor: AccountAuxiliaryViewInteractorAPI {

    // MARK: - Types

    private typealias LocalizationIds = LocalizationConstants.Transaction

    // MARK: - State

    struct State {
        let title: String
        let subtitle: String
        let imageResource: ImageResource
        let isEnabled: Bool

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

    func connect(stream: Observable<BlockchainAccount>, accounts: Observable<[BlockchainAccount]>) -> Disposable {
        Observable.zip(
            stream,
            accounts
                .map(\.count)
                .map { $0 > 1 }
        )
        .map { account, tapEnabled -> State in
            switch account {
            case let bank as LinkedBankAccount:
                let type = bank.accountType.title
                let description = type + (type.isEmpty ? "" : " ") + "\(LocalizationIds.account) -"
                let subtitle = description + " \(bank.accountNumber)"
                return .init(
                    title: bank.label,
                    subtitle: subtitle,
                    imageResource: bank.logoResource,
                    isEnabled: tapEnabled
                )
            default:
                unimplemented()
            }
        }
        .bindAndCatch(to: stateRelay)
    }
}
