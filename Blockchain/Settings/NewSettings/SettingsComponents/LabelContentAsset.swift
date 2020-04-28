//
//  LabelContentAsset.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit

public struct LabelContentAsset {
    
    public struct State {
        
        /// The state of the `LabelItem` interactor and presenter
        public struct LabelItem {
            public typealias Interaction = LoadingState<Value.Interaction.LabelItem>
            public typealias Presentation = LoadingState<Value.Presentation.LabelItem>
        }
    }
    
    public struct Value {
        public struct Interaction {
            public struct LabelItem {
                public let text: String
            }
        }
        
        public struct Presentation {
            
            public struct LabelItem {
                
                /// Descriptors that allows customized content and style
                public struct Descriptors {
                    
                    public enum FontType {
                        case regular
                        case medium
                        case semiBold
                        case bold
                    }
                    
                    let fontType: FontType
                    let contentColor: UIColor
                    let titleFontSize: CGFloat
                    let accessibilityIdSuffix: String
                    
                    init(
                        fontType: FontType = .medium,
                        contentColor: UIColor = .titleText,
                        titleFontSize: CGFloat,
                        accessibilityIdSuffix: String
                    ) {
                        self.fontType = fontType
                        self.contentColor = contentColor
                        self.titleFontSize = titleFontSize
                        self.accessibilityIdSuffix = accessibilityIdSuffix
                    }
                }
                
                let labelContent: LabelContent
                
                public init(with value: Interaction.LabelItem, descriptors: Descriptors) {
                    labelContent = LabelContent(
                        text: value.text,
                        font: descriptors.font,
                        color: descriptors.contentColor,
                        accessibility: .init(id: .value(descriptors.accessibilityIdSuffix))
                    )
                }
            }
        }
    }
}

extension LabelContentAsset.Value.Presentation.LabelItem.Descriptors {
    
    public typealias Descriptors = LabelContentAsset.Value.Presentation.LabelItem.Descriptors
    
    var font: UIFont {
        switch fontType {
        case .regular:
            return .mainRegular(titleFontSize)
        case .medium:
            return .mainMedium(titleFontSize)
        case .bold:
            return .mainBold(titleFontSize)
        case .semiBold:
            return .mainSemibold(titleFontSize)
        }
    }
    
    /// Returns a descriptor for a settings cell
    public static var settings: Descriptors {
        return .init(
            titleFontSize: 16,
            accessibilityIdSuffix: Accessibility.Identifier.Settings.SettingsCell.titleLabelFormat
        )
    }
    
    /// Returns a descriptor for a disclaimer in a `Settings` cell.
    public static var disclaimer: Descriptors {
        return .init(
            titleFontSize: 12,
            accessibilityIdSuffix: Accessibility.Identifier.Settings.SettingsCell.titleLabelFormat
        )
    }
    
    public static var lineItemTitle: Descriptors {
        return .init(
            fontType: .medium,
            contentColor: .descriptionText,
            titleFontSize: 14,
            accessibilityIdSuffix: Accessibility.Identifier.Settings.SettingsCell.titleLabelFormat
        )
    }
    
    public static var lineItemDescription: Descriptors {
        return .init(
            fontType: .semiBold,
            contentColor: .textFieldText,
            titleFontSize: 16,
            accessibilityIdSuffix: Accessibility.Identifier.Settings.SettingsCell.titleLabelFormat
        )
    }
    
    public static func success(fontSize: CGFloat, accessibilityIdSuffix: String) -> Descriptors {
        return .init(
            contentColor: .positivePrice,
            titleFontSize: fontSize,
            accessibilityIdSuffix: accessibilityIdSuffix
        )
    }
}

extension LoadingState where Content == LabelContentAsset.Value.Presentation.LabelItem {
    init(with state: LoadingState<LabelContentAsset.Value.Interaction.LabelItem>,
         descriptors: LabelContentAsset.Value.Presentation.LabelItem.Descriptors) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(
                next: .init(
                    with: content,
                    descriptors: descriptors
                )
            )
        }
    }
}

