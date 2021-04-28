//
//  SavingsServiceAPI.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

public protocol SavingsOverviewAPI {
    func rate(for currency: CryptoCurrency) -> Single<Double>
}
