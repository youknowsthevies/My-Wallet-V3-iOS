//
//  AnyMock.swift
//  ERC20KitTests
//
//  Created by Paulo on 27/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import ERC20Kit
import EthereumKit
import PlatformKit
import RxSwift

public class AnyERC20BalanceServiceMock<Token: ERC20Token>: ERC20BalanceServiceAPI {
    var balanceResponse: Single<ERC20TokenValue<Token>> = Single.just(.zero())

    public var balanceForDefaultAccount: Single<ERC20TokenValue<Token>> {
        balanceResponse
    }
    public func balance(for address: EthereumAddress) -> Single<ERC20TokenValue<Token>> {
        balanceResponse
    }
}
