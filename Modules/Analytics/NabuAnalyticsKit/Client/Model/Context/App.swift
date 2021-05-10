// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct App: Encodable {
    let version: String? = Bundle.applicationVersion
    let build: String? = Bundle.applicationBuildVersion
}
