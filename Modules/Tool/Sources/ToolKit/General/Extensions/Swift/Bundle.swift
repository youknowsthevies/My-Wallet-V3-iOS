// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Bundle {

    public func url(for resource: (name: String, extension: String)) -> URL? {
        url(forResource: resource.name, withExtension: resource.extension)
    }
}

extension String {

    public var fileNameAndExtension: (name: String, extension: String) {
        guard let extIndex = lastIndex(of: ".") else { return (self, "") }
        return (String(self[..<extIndex]), String(self[extIndex...]))
    }
}
