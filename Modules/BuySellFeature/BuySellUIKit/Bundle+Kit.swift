//
//  Bundle+Kit.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 11/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension Bundle {
    private class BuySellKitBundle { }
    static let buySellKit: Bundle = Bundle(for: BuySellKitBundle.self)
}
