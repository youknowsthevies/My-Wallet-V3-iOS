// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

enum CustomerSupportChatConfiguration {

    // MARK: - Public

    static var apiKey: String {
        guard let value = infoDictionary[key] as? String else {
            return ""
        }
        return value
    }

    static var appId: String {
        guard let value = infoDictionary[applicationId] as? String else {
            return ""
        }
        return value
    }

    // MARK: - Private

    private static let applicationId = "intercomAppId"
    private static let key = "intercomAPIKey"

    private static var infoDictionary: [String: Any] {
        guard let infoDictionary = MainBundleProvider.mainBundle.infoDictionary else {
            return [:]
        }
        return infoDictionary
    }
}
