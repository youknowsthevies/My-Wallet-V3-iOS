// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

enum ObservabilityConfiguration {

    // MARK: - Public

    static var appId: String {
        guard let value = infoDictionary[applicationId] as? String else {
            preconditionFailure("Embrace App ID must be in the configuration.")
        }
        return value
    }

    // MARK: - Private

    private static let applicationId = "embraceAppId"

    private static var infoDictionary: [String: Any] {
        guard let infoDictionary = MainBundleProvider.mainBundle.infoDictionary else {
            return [:]
        }
        return infoDictionary
    }
}
