// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

public enum ImageResource {
    case local(name: String, bundle: Bundle)
    // case remote(url: String)

    public var local: (name: String, bundle: Bundle) {
        switch self {
        case let .local(name, bundle):
            return (name, bundle)
        }
    }

    public var localImage: UIImage? {
        switch self {
        case let .local(name, bundle):
            return UIImage(named: name, in: bundle, with: nil)
        }
    }
}
