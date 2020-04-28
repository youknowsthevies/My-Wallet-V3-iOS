//
//  Accessibility+SelectionButtonView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 28/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

extension Accessibility.Identifier {
    enum SelectionButtonView {
        private static let prefix = "SelectionView.%@."
        static let label = "\(prefix)title"
        static let subtitle = "\(prefix)subtitle"
        static let leadingContent = "\(prefix)leadingContent"
        static let trailingImage = "\(prefix)trailingImage"
        static let button = "\(prefix)button"
    }
}
