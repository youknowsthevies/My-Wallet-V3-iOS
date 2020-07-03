//
//  NabuAuthenticationExecutorMock.swift
//  PlatformKitTests
//
//  Created by Daniel on 30/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

@testable import PlatformKit

final class NabuAuthenticationExecutorMock: NabuAuthenticationExecutorAPI {
    
    var token: Single<String> { fatalError("TODO") }

    func authenticate<Response>(singleFunction: @escaping (String) -> Single<Response>) -> Single<Response> {
        fatalError("TODO")
    }
}
