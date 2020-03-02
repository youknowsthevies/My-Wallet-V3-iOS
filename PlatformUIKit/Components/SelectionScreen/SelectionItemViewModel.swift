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
    
    public var accessibilityId: String { name }
    public var description: String { id }
    
    public let id: String
    public let name: String
    public let thumbImage: ThumbImage
    
    public init(id: String, name: String, thumbImage: ThumbImage) {
        self.id = id
        self.name = name
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
        return lhs.name < rhs.name
    }
}
