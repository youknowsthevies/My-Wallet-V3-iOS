// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum CustomerSupportChatConfiguration {

    // MARK: - Public

    static var apiKey: String {
        guard let value = infoDictionary[key] as? String else {
            return ""
        }
        return value
    }

    // MARK: - Private

    private static let key = "zenDeskAccountKey"

    private static var infoDictionary: [String: Any] {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            return [:]
        }
        return infoDictionary
    }
}
