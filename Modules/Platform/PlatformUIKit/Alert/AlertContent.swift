// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AlertViewContent {
    
    public typealias Action = ((UIAlertAction) -> Void)

    public let title: String
    public let message: String
    
    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}
