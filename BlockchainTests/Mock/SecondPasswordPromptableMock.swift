//
//  SecondPasswordPromptableMock.swift
//  BlockchainTests
//
//  Created by Paulo on 15/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import Blockchain
import RxSwift

final class SecondPasswordPromptableMock: SecondPasswordPromptable {
    var underlyingSecondPasswordIfNeeded: Single<String?> = .just(nil)
    func secondPasswordIfNeeded(type: PasswordScreenType) -> Single<String?> {
        underlyingSecondPasswordIfNeeded
    }
}
