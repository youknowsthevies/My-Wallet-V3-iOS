//
//  LinkedBankViewModel.swift
//  BuySellUIKit
//
//  Created by Daniel on 16/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxDataSources
import Localization

public final class LinkedBankViewModel {
    
    // MARK: - Types
    
    private typealias AccessibilityId = Accessibility.Identifier.LinkedBankView
    
    // MARK: - Properties
    
    public let data: Beneficiary
    
    let nameLabelContent: LabelContent
    let limitLabelContent: LabelContent
    let accountLabelContent: LabelContent
    let badgeImageViewModel: BadgeImageViewModel
    
    // MARK: - Setup
    
    public init(data: Beneficiary) {
        self.data = data
        
        badgeImageViewModel = .template(
            with: "icon-bank",
            templateColor: .secondary,
            backgroundColor: .clear,
            cornerRadius: .value(0),
            accessibilityIdSuffix: data.identifier
        )
        badgeImageViewModel.marginOffsetRelay.accept(0)
        
        nameLabelContent = LabelContent(
            text: data.name,
            font: .main(.semibold, 16),
            color: .titleText,
            accessibility: .id("\(AccessibilityId.name)\(data.identifier)")
        )
        
        var limitText = ""
        if let limit = data.limit {
            limitText = "\(limit.toDisplayString(includeSymbol: true)) \(LocalizationConstants.Settings.Bank.dailyLimit)"
        }
        
        limitLabelContent = LabelContent(
            text: limitText,
            font: .main(.medium, 14),
            color: .descriptionText,
            accessibility: .id("\(AccessibilityId.limits)\(data.identifier)")
        )
        
        accountLabelContent = LabelContent(
            text: data.account,
            font: .main(.semibold, 16),
            color: .titleText,
            accessibility: .id("\(AccessibilityId.account)\(data.identifier)")
        )
    }
}

extension LinkedBankViewModel: IdentifiableType {
    public var identity: String {
        data.identifier
    }
}

extension LinkedBankViewModel: Equatable {
    public static func == (lhs: LinkedBankViewModel, rhs: LinkedBankViewModel) -> Bool {
        lhs.data == rhs.data
    }
}

private extension Accessibility.Identifier {
    enum LinkedBankView {
        private static let prefix = "LinkedBankView."
        static let image = "\(prefix)image"
        static let name = "\(prefix)name."
        static let limits = "\(prefix)limits."
        static let account = "\(prefix)account."
    }
}
