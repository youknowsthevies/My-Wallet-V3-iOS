// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct AppStoreResponse: Decodable {

    struct Application: Decodable {
        let version: String
    }

    let results: [Application]
}
