//
//  SelectionButtonViewModel+PaymentMethodType.swift
//  Blockchain
//
//  Created by Daniel Huri on 08/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import PlatformUIKit
import BuySellKit

extension SelectionButtonViewModel {
    
    // MARK: - Types
    
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.PaymentMethodSelectionScreen
    
    // MARK: - Setup
    
    convenience init(with paymentMethodType: PaymentMethodType) {
        self.init()
        let leadingContent: SelectionButtonViewModel.LeadingContentType?
        let title: String
        let accessibilityContent: AccessibilityContent
        switch paymentMethodType {
        case .suggested(let method):
            switch method.type {
            case .card:
                leadingContent = .image(
                    .init(
                        name: "icon-card",
                        background: .lightBlueBackground,
                        offset: 4,
                        cornerRadius: .round,
                        size: .init(edge: 32)
                    )
                )
                title = LocalizedString.Types.cardTitle
            case .bankTransfer:
                leadingContent = .image(
                    .init(
                        name: "icon-bank",
                        background: .lightBlueBackground,
                        offset: 4,
                        cornerRadius: .round,
                        size: .init(edge: 32)
                    )
                )
                title = LocalizedString.Types.bankWireTitle
            }
            subtitleRelay.accept("\(method.max.toDisplayString()) \(LocalizedString.Types.limitSubtitle)")
            accessibilityContent = AccessibilityContent(
                id: method.type.rawValue,
                label: title
            )
        case .card(let data):
            if let thumbnail = data.type.thumbnail {
                leadingContent = .image(
                    .init(
                        name: thumbnail,
                        background: .background,
                        offset: 0,
                        cornerRadius: .value(4),
                        size: .init(width: 32, height: 20)
                    )
                )
            } else {
                leadingContent = nil
            }
            title = data.label
            accessibilityContent = AccessibilityContent(
                id: title,
                label: title
            )
            let limit = "\(data.topLimitDisplayValue) \(LocalizedString.Types.limitSubtitle)"
            subtitleRelay.accept(limit)
        }
        accessibilityContentRelay.accept(accessibilityContent)
        leadingContentTypeRelay.accept(leadingContent)
        titleRelay.accept(title)
    }
}

// MARK: - Array extension

extension Array where Element == SelectionButtonViewModel {
    init(with paymentMethods: [PaymentMethodType]) {
        self.init()
        append(contentsOf: paymentMethods.map { SelectionButtonViewModel(with: $0) })
    }
}
