//
//  LabelContent+StateValue.swift
//  PlatformUIKit
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

extension LabelContent {
    public enum State {
        /// The state of the `LabelItem` interactor and presenter
        public typealias Interaction = LoadingState<LabelContent.Value.Interaction.Content>
        public typealias Presentation = LoadingState<LabelContent.Value.Presentation.Content>
    }
    public enum Value {
        public enum Interaction { }
        public enum Presentation { }
    }
}

extension LabelContent.Value.Interaction {

   public struct Content {
        public let text: String
        public init(text: String) {
            self.text = text
        }
    }
}

extension LabelContent.Value.Presentation {

   public struct Content {

        /// Descriptors that allows customized content and style
        public struct Descriptors {

            let fontWeight: FontWeight
            let contentColor: UIColor
            let fontSize: CGFloat
            let accessibilityIdSuffix: String

            public init(
                fontWeight: FontWeight = .medium,
                contentColor: UIColor = .titleText,
                fontSize: CGFloat,
                accessibilityIdSuffix: String
            ) {
                self.fontWeight = fontWeight
                self.contentColor = contentColor
                self.fontSize = fontSize
                self.accessibilityIdSuffix = accessibilityIdSuffix
            }
        }

        public let labelContent: LabelContent

        public init(with value: LabelContent.Value.Interaction.Content, descriptors: Descriptors) {
            labelContent = LabelContent(
                text: value.text,
                font: .main(descriptors.fontWeight, descriptors.fontSize),
                color: descriptors.contentColor,
                accessibility: .init(id: .value(descriptors.accessibilityIdSuffix))
            )
        }
    }
}

extension LabelContent.Value.Presentation.Content.Descriptors {

    public typealias Descriptors = LabelContent.Value.Presentation.Content.Descriptors

    /// Returns a descriptor for a disclaimer in a `Settings` cell.
    public static var disclaimer: Descriptors {
        Descriptors(
            fontSize: 12,
            accessibilityIdSuffix: Accessibility.Identifier.Settings.SettingsCell.titleLabelFormat
        )
    }

    public static var lineItemTitle: Descriptors {
        Descriptors(
            fontWeight: .medium,
            contentColor: .descriptionText,
            fontSize: 14,
            accessibilityIdSuffix: Accessibility.Identifier.Settings.SettingsCell.titleLabelFormat
        )
    }

    public static var lineItemDescription: Descriptors {
        Descriptors(
            fontWeight: .semibold,
            contentColor: .textFieldText,
            fontSize: 16,
            accessibilityIdSuffix: Accessibility.Identifier.Settings.SettingsCell.titleLabelFormat
        )
    }

    public static func success(fontSize: CGFloat, accessibilityIdSuffix: String) -> Descriptors {
        Descriptors(
            contentColor: .positivePrice,
            fontSize: fontSize,
            accessibilityIdSuffix: accessibilityIdSuffix
        )
    }
}

public extension LoadingState where Content == LabelContent.Value.Presentation.Content {
    init(with state: LoadingState<LabelContent.Value.Interaction.Content>,
         descriptors: LabelContent.Value.Presentation.Content.Descriptors) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(next: Content(with: content, descriptors: descriptors))
        }
    }
}

