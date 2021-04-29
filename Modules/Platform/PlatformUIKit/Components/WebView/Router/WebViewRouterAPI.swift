// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay

/// A routing API to any web view.
public protocol WebViewRouterAPI: class {
    var launchRelay: PublishRelay<TitledLink> { get }
}

