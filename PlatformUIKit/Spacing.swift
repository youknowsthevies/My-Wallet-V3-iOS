//
//  Spacing.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 6/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct LayoutUnit {
    private static let unit: CGFloat = 8.0
    public static let standard = unit
}

public struct Spacing {
    public static let interItem: CGFloat = LayoutUnit.standard / 2.0
    public static let standard: CGFloat = LayoutUnit.standard
    public static let outer: CGFloat = LayoutUnit.standard * 3
    public static let inner: CGFloat = LayoutUnit.standard * 2
}

public struct Sizing {
    public static let badge: CGFloat = LayoutUnit.standard * 4
}
