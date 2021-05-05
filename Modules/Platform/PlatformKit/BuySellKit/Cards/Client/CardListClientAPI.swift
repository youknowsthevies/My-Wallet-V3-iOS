// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol CardListClientAPI: class {
    var cardList: Single<[CardPayload]> { get }
}
