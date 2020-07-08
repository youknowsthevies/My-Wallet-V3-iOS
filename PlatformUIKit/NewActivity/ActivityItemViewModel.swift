//
//  ActivityItemViewModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 4/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import RxDataSources
import ToolKit

public final class ActivityItemViewModel: IdentifiableType, Hashable {
    
    typealias AccessibilityId = Accessibility.Identifier.Activity
    typealias LocalizationStrings = LocalizationConstants.Activity.MainScreen.Item
    
    public typealias Descriptors = DashboardAsset.Value.Presentation.AssetBalance.Descriptors

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
        case .product(let status):
            // TODO: Handle Product Status
            return .activity(
                cryptoAccessiblitySuffix: accessibility.cryptoValuePrefix,
                fiatAccessiblitySuffix: accessibility.fiatValuePrefix
            )
        }
    }
    
    public var titleLabelContent: LabelContent {
        var text = ""
        switch event {
        case .buy(let orderDetails):
            text = "\(LocalizationStrings.buy) \(orderDetails.cryptoValue.currencyType.name)"
        case .swap(let event):
            let pair = event.pair
            text = "\(LocalizationStrings.swap) \(pair.from.displayCode) -> \(pair.to.displayCode)"
        case .transactional(let event):
            switch event.type {
            case .receive:
                text = LocalizationStrings.receive + " \(event.currency.displayCode)"
            case .send:
                text = LocalizationStrings.send + " \(event.currency.displayCode)"
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
            // TODO: Should swap event status be accounted for here?
            // TODO: Should `Buy` event status be accounted for here?
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
        case .buy(let orderDetails):
            return orderDetails.cryptoValue.currencyType.brandColor
        case .swap(let event):
            return event.pair.from.brandColor
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
        case .buy:
            return "plus-icon"
        case .swap:
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
