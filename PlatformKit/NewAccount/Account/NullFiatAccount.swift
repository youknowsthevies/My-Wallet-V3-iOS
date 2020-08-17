//
//  NullFiatAccount.swift
//  PlatformKit
//
//  Created by Paulo on 03/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public class NullFiatAccount : FiatAccount {

    public var id: String {
        ""
    }

    public var fiatCurrency: String {
        unimplemented()
    }

    public var receiveAddress: Single<ReceiveAddress> {
        .error(ReceiveAddressError.notSupported)
    }

    public var isDefault: Bool {
        unimplemented()
    }

    public var sendState: Single<SendState> {
        .just(.notSupported)
    }

    public func createSendProcessor(address: ReceiveAddress) -> Single<SendProcessor> {
        unimplemented()
    }

    public var label: String {
        unimplemented()
    }

    public var balance: Single<MoneyValue> {
        unimplemented()
    }

    public var actions: AvailableActions {
        unimplemented()
    }

    public var isFunded: Bool {
        unimplemented()
    }

    public func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue> {
        unimplemented()
    }
}
