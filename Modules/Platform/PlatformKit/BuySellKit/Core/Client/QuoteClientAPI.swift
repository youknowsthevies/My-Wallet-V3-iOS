// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol QuoteClientAPI: class {
    func getQuote(for action: Order.Action,
                  to cryptoCurrency: CryptoCurrency,
                  amount: FiatValue) -> Single<QuoteResponse>
}
