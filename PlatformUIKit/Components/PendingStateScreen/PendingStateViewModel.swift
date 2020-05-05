//
//  PendingStateViewModel.swift
//  PlatformUIKit
//
//  Created by Paulo on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

public struct PendingStateViewModel {
    public enum Image {
        case triangleError
        case clock
        case region
        case circleError
        case success
        case cutsom(String)
        
        public var name: String {
            switch self {
            case .circleError:
                return "circular-error-icon"
            case .region:
                return "region-error-icon"
            case .triangleError:
                return "triangle-error-icon"
            case .clock:
                return "clock-error-icon"
            case .success:
                return "v-success-icon"
            case .cutsom(let name):
                return name
            }
        }
    }

    let compositeStatusViewType: CompositeStatusViewType
    let title: NSAttributedString
    let subtitle: NSAttributedString
    let button: ButtonViewModel?
    
    static private func title(_ string: String) -> NSAttributedString {
        return NSAttributedString(
            string,
            font: .main(.regular, 20),
            color: .titleText
        )
    }
    
    static private func subtitle(_ string: String) -> NSAttributedString {
        return NSAttributedString(
            string,
            font: .main(.regular, 14),
            color: .descriptionText
        )
    }
    
    public init(compositeStatusViewType: CompositeStatusViewType,
                title: String,
                subtitle: String,
                button: ButtonViewModel? = nil) {
        self.compositeStatusViewType = compositeStatusViewType
        self.title = Self.title(title)
        self.subtitle = Self.subtitle(subtitle)
        self.button = button
    }
}
