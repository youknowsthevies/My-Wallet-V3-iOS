//
//  Bundle+Kit.swift
//  KYCUIKit
//
//  Created by Paulo on 07/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

extension Bundle {
    private class KYCUIKitBundle { }
    public static let kycUIKit: Bundle = Bundle(for: KYCUIKitBundle.self)
}
