//
//  Bundle+Kit.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 24/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

extension Bundle {
    private class PlatformUIKitBundle { }
    public static let platformUIKit: Bundle = Bundle(for: PlatformUIKitBundle.self)
}
