//
//  SettingsServiceMock.swift
//  PlatformKitTests
//
//  Created by Daniel on 30/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

@testable import PlatformKit

final class SettingsServiceMock: SettingsServiceAPI {
        
    var expectedResult: Result<WalletSettings, Error>!

    func fetch(force: Bool) -> Single<WalletSettings> {
        expectedResult.single
    }
    
    var valueSingle: Single<WalletSettings> {
        expectedResult.single
    }
    
    var valueObservable: Observable<WalletSettings> {
        expectedResult.single.asObservable()
    }
}

