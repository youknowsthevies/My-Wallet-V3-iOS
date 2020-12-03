//
//  KeyPairProviderAPI.swift
//  PlatformKit
//
//  Created by AlexM on 11/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

@available(*, deprecated, message: "Use KeyPairProviderNewAPI, we want to move off `Maybe` based APIs")
public protocol KeyPairProviderAPI {
    associatedtype Pair: KeyPair
    func loadKeyPair() -> Maybe<Pair>
}

public protocol KeyPairProviderNewAPI {
    associatedtype Pair: KeyPair
    
    var keyPair: Single<Pair> { get }
}

public class AnyKeyPairProviderNew<Pair: KeyPair>: KeyPairProviderNewAPI {
    
    // MARK: - KeyPairProviderNewAPI
    
    public var keyPair: Single<Pair> {
        keyPairProvider
    }
    
    // MARK: - Private methods
    
    private let keyPairProvider: Single<Pair>
    
    // MARK: - Init
    
    public init<P: KeyPairProviderNewAPI>(provider: P) where P.Pair == Pair {
        self.keyPairProvider = provider.keyPair
    }
}
