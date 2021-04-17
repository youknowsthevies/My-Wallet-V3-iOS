//
//  SharedKeyRepositoryCombineAPI.swift
//  PlatformKit
//
//  Created by Jack Pooley on 10/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine

public protocol SharedKeyRepositoryCombineAPI: class {
    
    /// Streams `Bool` indicating whether the shared key is currently cached in the repo
    var hasSharedKeyPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Streams the cached shared key or `nil` if it is not cached
    var sharedKeyPublisher: AnyPublisher<String?, Never> { get }
    
    /// Sets the shared key
    func setPublisher(sharedKey: String) -> AnyPublisher<Void, Never>
}

extension SharedKeyRepositoryCombineAPI {
    
    public var hasSharedKeyPublisher: AnyPublisher<Bool, Never> {
        sharedKeyPublisher
            .map { sharedKey -> Bool in
                guard let sharedKey = sharedKey else { return false }
                return !sharedKey.isEmpty
            }
            .eraseToAnyPublisher()
    }
}
