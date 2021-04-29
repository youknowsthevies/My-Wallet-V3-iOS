// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol CardDetailClientAPI: class {
    func getCard(by id: String) -> Single<CardPayload>
}
