// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift
import ToolKit

@testable import PlatformKit

final class SettingsServiceMock: SettingsServiceAPI {

    var singleValuePublisher: AnyPublisher<WalletSettings, SettingsServiceError> {
        expectedResult.publisher.eraseToAnyPublisher()
    }

    var valuePublisher: AnyPublisher<WalletSettings, SettingsServiceError> {
        expectedResult.publisher.eraseToAnyPublisher()
    }

    func fetchPublisher(force: Bool) -> AnyPublisher<WalletSettings, SettingsServiceError> {
        expectedResult.publisher.eraseToAnyPublisher()
    }

    var expectedResult: Result<WalletSettings, SettingsServiceError>!

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
