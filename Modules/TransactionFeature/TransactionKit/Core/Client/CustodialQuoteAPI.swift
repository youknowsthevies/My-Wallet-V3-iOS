// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol CustodialQuoteAPI {
    func fetchQuoteResponse(with request: OrderQuoteRequest) -> Single<OrderQuoteResponse>
}
