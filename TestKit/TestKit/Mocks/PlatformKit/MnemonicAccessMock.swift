//
//  MnemonicAccessMock.swift
//  PlatformKit
//
//  Created by Paulo on 11/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

class MnemonicAccessMock: MnemonicAccessAPI {
    
    func mnemonic(with secondPassword: String?) -> Single<Mnemonic> {
        .never()
    }
    
    var mnemonic: Maybe<Mnemonic> = .empty()

    var mnemonicPromptingIfNeeded: Maybe<Mnemonic> = .empty()
    
    init() { }
}
