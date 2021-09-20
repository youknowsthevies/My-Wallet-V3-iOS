// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import PlatformKit
import RxCocoa
import RxSwift

/// `PITConnectionStatusProviding` is an API for determining if the user
/// has connected their wallet to the PIT
public protocol PITConnectionStatusProviding {
    var hasLinkedPITAccount: Observable<Bool> { get }
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

public final class PITConnectionStatusProvider: PITConnectionStatusProviding {

    // MARK: - PITConnectionStatusProviding

    public let fetchTriggerRelay = PublishRelay<Void>()

    // MARK: - Private Properties

    private let nabuUserService: NabuUserServiceAPI

    public init(nabuUserService: NabuUserServiceAPI = resolve()) {
        self.nabuUserService = nabuUserService
    }

    public var hasLinkedPITAccount: Observable<Bool> {
        fetchTriggerRelay
            .flatMap { [nabuUserService] _ in
                nabuUserService.fetchUser().asObservable()
            }
            .map(\.hasLinkedExchangeAccount)
    }
}
