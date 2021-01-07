//
//  LinkedBankViewModel.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 08/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxDataSources

public final class LinkedBankViewModel: LinkedBankViewModelAPI {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.LinkedBankView

    // MARK: - Properties

    public let data: LinkedBankData

    public let nameLabelContent: LabelContent
    public let limitLabelContent: LabelContent
    public let accountLabelContent: LabelContent
    public let badgeImageViewModel: BadgeImageViewModel

    public let isCustomButtonEnabled: Bool = true

    public let tapRelay = PublishRelay<Void>()
    public var tap: Signal<Void> {
        tapRelay.asSignal()
    }

    // MARK: - Setup

    public init(data: LinkedBankData) {
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
            text: data.account?.bankName ?? "",
            font: .main(.semibold, 16),
            color: .titleText,
            accessibility: .id("\(AccessibilityId.name)\(data.identifier)")
        )

        let accountName = data.account?.name ?? ""
        let accountNumber = data.account?.number ?? ""
        let detailsTitle = "\(accountName) \(accountNumber)"
        limitLabelContent = LabelContent(
            text: detailsTitle,
            font: .main(.medium, 14),
            color: .descriptionText,
            accessibility: .id("\(AccessibilityId.limits)\(data.identifier)")
        )

        accountLabelContent = LabelContent(
            text: "",
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
