// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI

public struct AssetDetails: Equatable {

    public let name: String
    public let code: String
    public var brandColor: Color
    public let about: String?
    public let website: URL?
    public let logoUrl: URL?
    public let logoImage: Image?
    public var isTradable: Bool

    public init(
        name: String,
        code: String,
        brandColor: Color,
        about: String?,
        website: URL?,
        logoUrl: URL?,
        logoImage: Image?,
        isTradable: Bool
    ) {
        self.name = name
        self.code = code
        self.brandColor = brandColor
        self.about = about
        self.website = website
        self.logoUrl = logoUrl
        self.logoImage = logoImage
        self.isTradable = isTradable
    }
}
