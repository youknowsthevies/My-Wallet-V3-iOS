// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AssetDetails: Equatable {

    public let name: String
    public let about: String
    public let url: URL

    public init(name: String, about: String, url: URL) {
        self.name = name
        self.about = about
        self.url = url
    }
}
