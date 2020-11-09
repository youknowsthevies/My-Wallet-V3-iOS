//
//  MnemonicComponentsProviding.swift
//  PlatformKit
//
//  Created by Jack Pooley on 09/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift

public protocol MnemonicComponentsProviding {
    
    /// Provides 12 word components of mnemonic
    var components: Observable<[String]> { get }
}

final class MnemonicComponentsProvider: MnemonicComponentsProviding {
    
    var components: Observable<[String]> {
        mnemonicAccessAPI.mnemonic
            .map { $0.components(separatedBy: " ") }
            .asObservable()
    }
    
    private let mnemonicAccessAPI: MnemonicAccessAPI
    
    init(mnemonicAccessAPI: MnemonicAccessAPI = resolve()) {
        self.mnemonicAccessAPI = mnemonicAccessAPI
    }
}
