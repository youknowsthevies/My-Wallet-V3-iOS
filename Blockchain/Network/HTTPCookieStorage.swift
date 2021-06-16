// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import ToolKit

extension HTTPCookieStorage {
    func deleteAllCookies() {
        let cookieStorage = HTTPCookieStorage.shared
        guard let cookies = cookieStorage.cookies else {
            Logger.shared.info("No cookies to delete")
            return
        }
        cookies.forEach { cookieStorage.deleteCookie($0) }
    }
}
