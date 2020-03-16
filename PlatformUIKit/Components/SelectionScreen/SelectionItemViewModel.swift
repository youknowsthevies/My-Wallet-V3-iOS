//
//  SelectionItemViewModel.swift
//  PlatformUIKit
//
//  Created by Jack on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct SelectionItemViewModel: Identifiable {
    
    public enum ThumbImage {
        case name(String)
        case none
    }
    
    public var accessibilityId: String { id }
    public let id: String
    
    public let title: String
    public var subtitle: String
    public let thumbImage: ThumbImage
    
    public init(id: String, title: String, subtitle: String, thumbImage: ThumbImage) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.thumbImage = thumbImage
    }
}

extension SelectionItemViewModel: Equatable {
    public static func == (lhs: SelectionItemViewModel, rhs: SelectionItemViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SelectionItemViewModel: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.title < rhs.title
    }
}
