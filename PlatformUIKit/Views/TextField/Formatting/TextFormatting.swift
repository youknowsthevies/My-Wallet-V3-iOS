//
//  TextFormatting.swift
//  PlatformUIKit
//
//  Created by AlexM on 2/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol TextFormatting: class {
    func format(text: String) -> Observable<String>
}

public final class EmptyFormatter: TextFormatting {
    public func format(text: String) -> Observable<String> {
        return Observable.just(text)
    }
}
