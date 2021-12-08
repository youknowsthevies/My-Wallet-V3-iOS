// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
@testable import MetadataDataKit
@testable import MetadataKit
import TestKit

extension MetadataResponse {

    static var rootMetadataResponse: MetadataResponse {
        Fixtures.load(name: "root_metadata_response", in: .module)!
    }
}
