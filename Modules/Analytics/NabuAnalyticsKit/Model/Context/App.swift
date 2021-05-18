// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct App: Encodable {
    let name: String? = Bundle.applicationName
    let version: String? = Bundle.applicationVersion
    let build: String? = Bundle.applicationBuildVersion
    let namespace: String? = Bundle.main.bundleIdentifier
}
