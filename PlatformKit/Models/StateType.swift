//
//  StateType.swift
//  PlatformKit
//
//  Created by Alex McGregor on 2/26/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

public protocol StateType {
    func update<Value>(keyPath: WritableKeyPath<Self, Value>, value: Value) -> Self
}

public extension StateType {
    func update<Value>(keyPath: WritableKeyPath<Self, Value>, value: Value) -> Self {
        var newState = self
        newState[keyPath: keyPath] = value
        return newState
    }
}
