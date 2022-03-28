// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay

protocol BitpayServiceProtocol: AnyObject {

    /// BitPayURL content
    var content: URL? { get set }
}
