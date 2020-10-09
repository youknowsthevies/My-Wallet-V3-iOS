//
//  Bundle+Kit.swift
//  TransactionUIKit
//
//  Created by Paulo on 02/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

extension Bundle {
    private class SendReceiveUIKitBundle { }
    static let sendReceiveUIKit: Bundle = Bundle(for: SendReceiveUIKitBundle.self)
}
