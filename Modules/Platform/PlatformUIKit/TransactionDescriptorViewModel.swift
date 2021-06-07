// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

struct BadgeImageAttributes {
    let imageResource: ImageResource
    let brandColor: UIColor
    let isFiat: Bool

    static let empty = BadgeImageAttributes(
        imageResource: .local(name: "", bundle: .platformUIKit),
        brandColor: .white,
        isFiat: false
    )

    init(_ currencyType: CurrencyType) {
        imageResource = currencyType.logoResource
        brandColor = currencyType.brandColor
        isFiat = currencyType.isFiatCurrency
    }

    init(imageResource: ImageResource, brandColor: UIColor, isFiat: Bool) {
        self.imageResource = imageResource
        self.brandColor = brandColor
        self.isFiat = isFiat
    }
}

public struct TransactionDescriptorViewModel {
    public var transactionTypeBadgeImageViewModel: Driver<BadgeImageViewModel> {
        guard adjustActionIconColor else {
            return Driver.just(
                provideBadgeImageViewModel(
                    accentColor: .primaryButton,
                    backgroundColor: .lightBlueBackground
                )
            )
        }
        return fromAccountRelay
            .compactMap(\.account)
            .map(\.currencyType)
            .map(BadgeImageAttributes.init)
            // This should not happen.
            .asDriver(onErrorJustReturn: .empty)
            .map { (attributes) -> BadgeImageViewModel in
                provideBadgeImageViewModel(
                    accentColor: attributes.brandColor,
                    backgroundColor: attributes.brandColor.withAlphaComponent(0.15)
                )
            }
    }

    public var fromAccountBadgeImageViewModel: Driver<BadgeImageViewModel> {
        fromAccountRelay
            .compactMap(\.account)
            .map(\.currencyType)
            .map(BadgeImageAttributes.init)
            // This should not happen.
            .asDriver(onErrorJustReturn: .empty)
            .map { (attributes) -> BadgeImageViewModel in
                var model: BadgeImageViewModel
                switch attributes.isFiat {
                case true:
                    let localImage = attributes.imageResource.local
                    model = BadgeImageViewModel.primary(
                        with: localImage.name,
                        bundle: localImage.bundle,
                        contentColor: .white,
                        backgroundColor: attributes.brandColor,
                        cornerRadius: attributes.isFiat ? .value(8.0) : .round,
                        accessibilityIdSuffix: ""
                    )
                case false:
                    let localImage = attributes.imageResource.local
                    model = BadgeImageViewModel.default(
                        with: localImage.name,
                        bundle: localImage.bundle,
                        cornerRadius: attributes.isFiat ? .value(8.0) : .round,
                        accessibilityIdSuffix: ""
                    )
                }
                model.marginOffsetRelay.accept(0)
                return model
            }
    }

    public var toAccountBadgeImageViewModel: Driver<BadgeImageViewModel> {
        toAccountRelay
            .compactMap(\.account)
            .map(\.currencyType)
            .map(BadgeImageAttributes.init)
            // This should not happen.
            .asDriver(onErrorJustReturn: .empty)
            .map { (attributes) -> BadgeImageViewModel in
                let localImage = attributes.imageResource.local
                let model = BadgeImageViewModel.default(
                    with: localImage.name,
                    bundle: localImage.bundle,
                    cornerRadius: attributes.isFiat ? .value(8.0) : .round,
                    accessibilityIdSuffix: ""
                )
                model.marginOffsetRelay.accept(0)
                return model
            }
    }

    public var toAccountBadgeIsHidden: Driver<Bool> {
        toAccountRelay
            .map(\.isEmpty)
            .asDriver(onErrorDriveWith: .empty())
    }

    private let assetAction: AssetAction
    private let adjustActionIconColor: Bool

    public init(assetAction: AssetAction, adjustActionIconColor: Bool = false) {
        self.assetAction = assetAction
        self.adjustActionIconColor = adjustActionIconColor
    }

    public enum TransactionAccountValue {
        case value(SingleAccount)
        case empty

        var account: SingleAccount? {
            switch self {
            case .value(let account):
                return account
            case .empty:
                return nil
            }
        }

        var isEmpty: Bool {
            switch self {
            case .value:
                return false
            case .empty:
                return true
            }
        }
    }

    /// The `SingleAccount` that the transaction is originating from
    public let fromAccountRelay = BehaviorRelay<TransactionAccountValue>(value: .empty)

    /// The `SingleAccount` that is the destination for the transaction
    public let toAccountRelay = BehaviorRelay<TransactionAccountValue>(value: .empty)

    public init(sourceAccount: SingleAccount? = nil,
                destinationAccount: SingleAccount? = nil,
                assetAction: AssetAction,
                adjustActionIconColor: Bool = false) {
        self.assetAction = assetAction
        self.adjustActionIconColor = adjustActionIconColor
        if let sourceAccount = sourceAccount {
            self.fromAccountRelay.accept(.value(sourceAccount))
        }
        if let destinationAccount = destinationAccount {
            self.toAccountRelay.accept(.value(destinationAccount))
        }
    }

    private func provideBadgeImageViewModel(accentColor: UIColor, backgroundColor: UIColor) -> BadgeImageViewModel {
        let viewModel = BadgeImageViewModel.template(
            with: assetAction.assetImageName,
            templateColor: accentColor,
            backgroundColor: backgroundColor,
            accessibilityIdSuffix: ""
        )
        viewModel.marginOffsetRelay.accept(0)
        return viewModel
    }
}

private extension AssetAction {
    var assetImageName: String {
        switch self {
        case .deposit:
            return "deposit-icon"
        case .receive:
            return "receive-icon"
        case .viewActivity:
            return "clock-icon"
        case .sell:
            return "minus-icon"
        case .send:
            return "send-icon"
        case .swap:
            return "swap-icon"
        case .withdraw:
            return "withdraw-icon"
        }
    }
}
