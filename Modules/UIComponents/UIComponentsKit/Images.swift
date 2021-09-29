// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public enum ImageAsset: String {
    case iconSend = "icon_send"
    case iconReceive = "icon_receive"
    case iconReceiveGray = "icon_receive_gray"
    case iconVerified = "icon_verified"
    case iconSwapTransaction = "icon_swap_transaction"

    case linkPattern = "link-pattern"

    public var imageResource: ImageResource {
        .local(name: rawValue, bundle: .module)
    }

    public var image: Image {
        Image(rawValue, bundle: .module)
    }
}
