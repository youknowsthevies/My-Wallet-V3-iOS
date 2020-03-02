//
//  MnemonicAccess.swift
//  PlatformKit
//
//  Created by AlexM on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public typealias Mnemonic = String

/// Users can double encrypt their wallet. If this is the case, sometimes users will
/// need to enter in their secondary password before performing certain actions. This is
/// **not** currency or asset specific
public protocol MnemonicAccessAPI {
    
    /// Returns a Maybe emmitting a Mnemonic if and only if the mnemonic is not double encrypted
    var mnemonic: Maybe<Mnemonic> { get }
    
    /// Returns a Maybe emitting a Mnemonic if and only if the user enters the correct second password
    /// in the presented prompt
    var mnemonicForcePrompt: Maybe<Mnemonic> { get }
    
    /// Returns a Maybe emitting a Mnemonic. This will prompt the user to enter the second password if needed.
    var mnemonicPromptingIfNeeded: Maybe<Mnemonic> { get }
}

public protocol MnemonicComponentsProviding {
    var components: Observable<[String]> { get }
}

public final class MnemonicComponentsProvider: MnemonicComponentsProviding {
    
    public var components: Observable<[String]> {
        return mnemonicAccessAPI.mnemonic.map {
            $0.components(separatedBy: " ")
        }.asObservable()
    }
    
    private let mnemonicAccessAPI: MnemonicAccessAPI
    
    public init(mnemonicAccessAPI: MnemonicAccessAPI) {
        self.mnemonicAccessAPI = mnemonicAccessAPI
    }
}
