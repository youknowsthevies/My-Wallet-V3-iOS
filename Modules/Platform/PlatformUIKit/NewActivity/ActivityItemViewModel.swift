// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxDataSources
import ToolKit

public final class ActivityItemViewModel: IdentifiableType, Hashable {

    typealias AccessibilityId = Accessibility.Identifier.Activity
    typealias LocalizationStrings = LocalizationConstants.Activity.MainScreen.Item

    public typealias Descriptors = AssetBalanceViewModel.Value.Presentation.Descriptors

    public var identity: AnyHashable {
        event
    }

    public var descriptors: Descriptors {
        let accessibility = AccessibilityId.ActivityCell.self
        switch event.status {
        case .pending:
            return .muted(
                cryptoAccessiblitySuffix: accessibility.cryptoValuePrefix,
                fiatAccessiblitySuffix: accessibility.fiatValuePrefix
            )
        case .complete:
            return .activity(
                cryptoAccessiblitySuffix: accessibility.cryptoValuePrefix,
                fiatAccessiblitySuffix: accessibility.fiatValuePrefix
            )
        case .product:
            return .activity(
                cryptoAccessiblitySuffix: accessibility.cryptoValuePrefix,
                fiatAccessiblitySuffix: accessibility.fiatValuePrefix
            )
        }
    }

    public var titleLabelContent: LabelContent {
        var text = ""
        switch event {
        case .buySell(let orderDetails):
            let prefix = orderDetails.isBuy ? LocalizationStrings.buy : LocalizationStrings.sell
            let postfix = orderDetails.isBuy ? orderDetails.outputValue.currencyType.name : orderDetails.inputValue.currencyType.name
            text = "\(prefix) \(postfix)"
        case .swap(let event):
            let pair = event.pair
            text = "\(LocalizationStrings.swap) \(pair.inputCurrencyType.displayCode) -> \(pair.outputCurrencyType.displayCode)"
        case .transactional(let event):
            switch event.type {
            case .receive:
                text = LocalizationStrings.receive + " \(event.currency.displayCode)"
            case .send:
                text = LocalizationStrings.send + " \(event.currency.displayCode)"
            }
        case .fiat(let event):
            let type = event.type
            switch type {
            case .deposit:
                text = LocalizationStrings.deposit + " \(event.fiatValue.currencyCode)"
            case .withdrawal:
                text = LocalizationStrings.withdraw + " \(event.fiatValue.currencyCode)"
            case .unknown:
                text = ""
            }
        }
        return .init(
            text: text,
            font: descriptors.fiatFont,
            color: descriptors.fiatTextColor,
            alignment: .left,
            accessibility: .id(AccessibilityId.ActivityCell.titleLabel)
        )
    }

    public var descriptionLabelContent: LabelContent {
        switch event.status {
        case .pending(confirmations: let confirmations):
            return .init(
                text: "\(confirmations.current) \(LocalizationStrings.of) \(confirmations.total)",
                font: descriptors.cryptoFont,
                color: descriptors.cryptoTextColor,
                alignment: .left,
                accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
            )
        case .complete:
            return .init(
                text: DateFormatter.medium.string(from: event.creationDate),
                font: descriptors.cryptoFont,
                color: descriptors.cryptoTextColor,
                alignment: .left,
                accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
            )
        case .product(let status):
            let failedLabelContent: LabelContent = .init(
                text: LocalizationStrings.failed,
                font: descriptors.cryptoFont,
                color: .destructive,
                alignment: .left,
                accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
            )

            switch status {
            case .fiat(let fiatStatus):
                if fiatStatus == .failed || fiatStatus == .rejected {
                    return failedLabelContent
                }
            case .buySell(let buySellStatus):
                if buySellStatus == .failed {
                    return failedLabelContent
                }
            case .swap(let swapStatus):
                if swapStatus == .failed {
                    return failedLabelContent
                }
            }

            return .init(
                text: DateFormatter.medium.string(from: event.creationDate),
                font: descriptors.cryptoFont,
                color: descriptors.cryptoTextColor,
                alignment: .left,
                accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
            )
        }
    }

    /// The color of the `EventType` image.
    public var eventColor: UIColor {
        switch event {
        case .buySell(let orderDetails):
            if orderDetails.status == .failed {
                return .destructive
            }

            switch orderDetails.isBuy {
            case true:
                return orderDetails.outputValue.currencyType.brandColor
            case false:
                return orderDetails.inputValue.currencyType.brandColor
            }
        case .swap(let event):
            if event.status == .failed {
                return .destructive
            }

            return event.pair.inputCurrencyType.brandColor
        case .fiat(let event):
            if event.status == .failed || event.status == .rejected {
                return .destructive
            }

            return .fiat
        case .transactional(let event):
            switch event.status {
            case .complete:
                return event.currency.brandColor
            case .pending:
                return .mutedText
            }
        }
    }

    /// The fill color of the `BadgeImageView`
    public var backgroundColor: UIColor {
        eventColor.withAlphaComponent(0.15)
    }

    /// The `imageName` for the `BadgeImageViewModel`
    public var imageName: String {
        switch event {
        case .buySell(let value):
            if value.status == .failed {
                return "activity-failed-icon"
            }

            return value.isBuy ? "plus-icon" : "minus-icon"
        case .fiat(let event):
            if event.status == .failed || event.status == .rejected {
                return "activity-failed-icon"
            }

            let type = event.type
            switch type {
            case .deposit:
                return "deposit-icon"
            case .withdrawal:
                return "withdraw-icon"
            case .unknown:
                return ""
            }
        case .swap(let event):
            if event.status == .failed {
                return "activity-failed-icon"
            }

            return "swap-icon"
        case .transactional(let event):
            if case .pending = event.status {
                return "clock-icon"
            }

            switch event.type {
            case .send:
                return "send-icon"
            case .receive:
                return "receive-icon"
            }
        }
    }
    public let event: ActivityItemEvent

    public init(event: ActivityItemEvent) {
        self.event = event
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(event)
    }

}

extension ActivityItemViewModel: Equatable {
    public static func ==(lhs: ActivityItemViewModel, rhs: ActivityItemViewModel) -> Bool {
        lhs.event == rhs.event
    }
}
