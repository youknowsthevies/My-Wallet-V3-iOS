//
//  ImageAsset.swift
//  TransactionUIKit
//
//  Created by Paulo on 02/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

enum ImageAsset: String, PlatformUIKit.ImageAsset {
    case iconSend = "icon_send"
    case iconReceive = "icon_receive"
    case iconReceiveGray = "icon_receive_gray"
    case iconVerified = "icon_verified"

    var image: UIImage {
        UIImage(named: rawValue, in: .transactionUIKit, compatibleWith: nil)!
    }
}
