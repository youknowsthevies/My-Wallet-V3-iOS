// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct OrdersActivityResponse: Decodable {
    let items: [FiatActivityItemEvent]
}
