//
//  MoneyOperating.swift
//  PlatformKit
//
//  Created by Jack Pooley on 25/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import ToolKit

public protocol MoneyOperating: MoneyImplementing {
    
    static func max(_ x: Self, _ y: Self) throws -> Self
    
    static func min(_ x: Self, _ y: Self) throws -> Self
}

public struct MoneyValueComparisonError: Error {
    let currencyType1: CurrencyType
    let currencyType2: CurrencyType
}

extension MoneyOperating {

    public static func max(_ x: Self, _ y: Self) throws -> Self {
        try ensureComparable(value: x, other: y)
        return try x > y ? x : y
    }

    public static func min(_ x: Self, _ y: Self) throws -> Self {
        try ensureComparable(value: x, other: y)
        return try x < y ? x : y
    }

    public static func > (lhs: Self, rhs: Self) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount > rhs.amount
    }

    public static func < (lhs: Self, rhs: Self) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount < rhs.amount
    }

    public static func >= (lhs: Self, rhs: Self) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount >= rhs.amount
    }

    public static func <= (lhs: Self, rhs: Self) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount <= rhs.amount
    }

    public static func + (lhs: Self, rhs: Self) throws -> Self {
        try ensureComparable(value: lhs, other: rhs)
        return Self.init(amount: lhs.amount + rhs.amount, currency: lhs.currencyType)
    }

    public static func - (lhs: Self, rhs: Self) throws -> Self {
        try ensureComparable(value: lhs, other: rhs)
        return Self.init(amount: lhs.amount - rhs.amount, currency: lhs.currencyType)
    }

    public static func * (lhs: Self, rhs: Self) throws -> Self {
        try ensureComparable(value: lhs, other: rhs)
        let amount = (lhs.amount * rhs.amount)
            .quotientAndRemainder(dividingBy: BigInt(10 ^^ lhs.maxDecimalPlaces))
            .quotient
        return Self.init(amount: amount, currency: lhs.currencyType)
    }

    public static func / (lhs: Self, rhs: Self) throws -> Self {
        try ensureComparable(value: lhs, other: rhs)
        let amount = (lhs.amount / rhs.amount) * BigInt(10 ^^ lhs.maxDecimalPlaces)
        return Self.init(amount: amount, currency: lhs.currencyType)
    }

    public static func += (lhs: inout Self, rhs: Self) throws {
        lhs = try lhs + rhs
    }

    public static func -= (lhs: inout Self, rhs: Self) throws {
        lhs = try lhs - rhs
    }

    public static func *= (lhs: inout Self, rhs: Self) throws {
        lhs = try lhs * rhs
    }

    public static func /= (lhs: inout Self, rhs: Self) throws {
        lhs = try lhs / rhs
    }
    
    private static func ensureComparable(value: Self, other: Self) throws {
        if value.currency != other.currency {
            throw MoneyValueComparisonError(currencyType1: value.currency, currencyType2: other.currency)
        }
    }
}
