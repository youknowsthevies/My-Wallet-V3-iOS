// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

public enum ImageResource: Hashable {
    public enum Resource {
        case image(UIImage)
        case url(URL)
    }

    case local(name: String, bundle: Bundle)
    case remote(url: String)

    public var resource: Resource? {
        switch self {
        case .local(let name, let bundle):
            guard let image = UIImage(named: name, in: bundle, compatibleWith: nil) else {
                return nil
            }
            return .image(image)
        case .remote(let urlString):
            guard let url = URL(string: urlString) else {
                return nil
            }
            return .url(url)
        }
    }
}
