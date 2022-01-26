// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol CardServiceAPI: AnyObject {
    var isEnteringDetails: Bool { get set }
}

class CardService: CardServiceAPI {
    var isEnteringDetails = false
}
