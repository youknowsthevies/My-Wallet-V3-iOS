// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

public enum ImageResource: Hashable {
    case local(name: String, bundle: Bundle)
    case remote(url: String)

    // TODO: IOS-4958: Remove this property.
    public var localImage: UIImage? {
        switch self {
        case let .local(name, bundle):
            return UIImage(named: name, in: bundle, with: nil)
        case .remote:
            return nil
        }
    }
}
