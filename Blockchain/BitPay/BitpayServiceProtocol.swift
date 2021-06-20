// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay

protocol BitpayServiceProtocol {

    /// BitPayURL content
    var contentRelay: BehaviorRelay<URL?> { get }
}
