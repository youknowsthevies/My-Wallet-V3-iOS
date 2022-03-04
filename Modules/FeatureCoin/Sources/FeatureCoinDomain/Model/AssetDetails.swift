// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI

public struct AssetDetails: Equatable {
    public let name: String
    public let code: String
    public var brandColor: Color
    public let about: String
    public let assetInfoUrl: URL
    public let logoUrl: URL?
    public let logoImage: Image?
    public var tradeable: Bool

    public init(
        name: String,
        code: String,
        brandColor: Color,
        about: String,
        assetInfoUrl: URL,
        logoUrl: URL?,
        logoImage: Image?,
        tradeable: Bool
    ) {
        self.name = name
        self.code = code
        self.brandColor = brandColor
        self.about = about
        self.assetInfoUrl = assetInfoUrl
        self.logoUrl = logoUrl
        self.logoImage = logoImage
        self.tradeable = tradeable
    }
}
