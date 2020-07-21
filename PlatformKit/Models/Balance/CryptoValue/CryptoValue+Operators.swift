//
//  CryptoValue+Operators.swift
//  PlatformKit
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct CryptoComparisonError: Error {
    let currencyType1: CryptoCurrency
    let currencyType2: CryptoCurrency
}

// MARK: - Operators

extension CryptoValue {

    private static func ensureComparable(value: CryptoValue, other: CryptoValue) throws {
        if value.currencyType != other.currencyType {
            throw CryptoComparisonError(currencyType1: value.currencyType, currencyType2: other.currencyType)
        }
    }

    public static func max(_ x: CryptoValue, _ y: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: x, other: y)
        return try x > y ? x : y
    }

    public static func min(_ x: CryptoValue, _ y: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: x, other: y)
        return try x < y ? x : y
    }

    public static func + (lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: lhs, other: rhs)
        return CryptoValue(currencyType: lhs.currencyType, amount: lhs.amount + rhs.amount)
    }

    public static func - (lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: lhs, other: rhs)
        return CryptoValue(currencyType: lhs.currencyType, amount: lhs.amount - rhs.amount)
    }

    public static func * (lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: lhs, other: rhs)
        return CryptoValue(currencyType: lhs.currencyType, amount: lhs.amount * rhs.amount)
    }

    public static func / (lhs: CryptoValue, rhs: CryptoValue) throws -> CryptoValue {
        try ensureComparable(value: lhs, other: rhs)
        return CryptoValue(currencyType: lhs.currencyType, amount: lhs.amount / rhs.amount)
    }

    public static func > (lhs: CryptoValue, rhs: CryptoValue) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount > rhs.amount
    }

    public static func < (lhs: CryptoValue, rhs: CryptoValue) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount < rhs.amount
    }

    public static func >= (lhs: CryptoValue, rhs: CryptoValue) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount >= rhs.amount
    }

    public static func <= (lhs: CryptoValue, rhs: CryptoValue) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount <= rhs.amount
    }

    public static func += (lhs: inout CryptoValue, rhs: CryptoValue) throws {
        lhs = try lhs + rhs
    }

    public static func -= (lhs: inout CryptoValue, rhs: CryptoValue) throws {
        lhs = try lhs - rhs
    }

    public static func *= (lhs: inout CryptoValue, rhs: CryptoValue) throws {
        lhs = try lhs * rhs
    }

    /// Calculates the value of `self` before a given percentage change
    public func value(before percentageChange: Double) throws -> CryptoValue {
        let percentageChange = percentageChange + 1
        guard percentageChange != 0 else {
            return .zero(currency: currencyType)
        }
        let majorAmount = displayMajorValue / Decimal(percentageChange)
        return CryptoValue(major: "\(majorAmount)", cryptoCurrency: currencyType)!
    }
}
