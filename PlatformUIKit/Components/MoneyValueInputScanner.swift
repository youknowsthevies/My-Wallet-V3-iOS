//
//  MoneyValueInputScanner.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 27/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

/// This class processes number input into a valid money value output.
/// This class is money agnostic and therefore can scan crypto as well
/// as fiat.
public final class MoneyValueInputScanner {
    
    // MARK: - Types
    
    /// An action to be performed on the input
    public enum Action {
        
        /// Removes a single character at the last indexed position
        case remove
        
        /// Inserts a given character at the last indexed position
        case insert(Character)
    }
    
    /// Represents an input
    public struct Input {
        
        /// A string input
        public let string: String
        
        /// A caret index of the next input
        let caretIndex: Int
        
        /// The amount string (prefix) - this is the firsrt part of the input which
        /// has been already inserted.
        var amount: String {
            guard !string.isEmpty else {
                return ""
            }
            return String(string[0..<caretIndex])
        }
        
        /// The padding string (suffix) - i.e the last part of the input which
        /// is yet to be inserted. might be empty in which case, the string
        /// is either full. e.g for values of `21.51` or `21`
        /// `padding` would be equal `nil`.
        var padding: String? {
            guard caretIndex < string.count else {
                return nil
            }
            return String(string[caretIndex..<string.count])
        }
        
        /// Emty input
        static var empty: Input {
            return Input(string: "", caretIndex: 0)
        }
        
        /// Zero input
        static var zero: Input {
            return Input(string: Constant.zero, caretIndex: 0)
        }
        
        init(string: String, caretIndex: Int) {
            self.string = string
            self.caretIndex = caretIndex
        }
        
        public init(string: String) {
            self.string = string
            self.caretIndex = string.count
        }
        
        public init(decimal: Decimal) {
            self.init(string: "\(decimal)")
        }
    }
    
    public enum Constant {
        public static let decimalSeparator = Locale.current.decimalSeparator ?? "."
        fileprivate static let decimalSeparatorChar = Character(decimalSeparator)
        fileprivate static let zero = "0"
        fileprivate static let doubleZero = "\(zero)\(zero)"
        fileprivate static let zeroChar = Character(zero)
        fileprivate static let allowedCharacters: CharacterSet = {
            var decimalDigits = CharacterSet.decimalDigits
            decimalDigits.insert(Constant.decimalSeparatorChar.unicodeScalars.first!)
            return decimalDigits
        }()
    }
    
    /// A current digit to be added to the input
    public let actionRelay = PublishRelay<Action>()
    
    /// Streams the input
    public var input: Observable<Input> {
        return inputRelay.asObservable()
    }
    
    public let inputRelay = BehaviorRelay(value: Input.empty)

    // MARK: - Private Properties
    
    /// The input relay (able to accept and stream `Input` values
    
    private let maxFractionDigits: Int
    private let maxIntegerDigits: Int
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(maxFractionDigits: Int, maxIntegerDigits: Int) {
        self.maxFractionDigits = maxFractionDigits
        self.maxIntegerDigits = maxIntegerDigits
        actionRelay
            .map(scan)
            .bind(to: inputRelay)
            .disposed(by: disposeBag)
        reset()
    }
    
    /// Resets the input to a single `0` character.
    public func reset() {
        inputRelay.accept(.empty)
        actionRelay.accept(.insert(Constant.zeroChar))
    }
    
    // MARK: - Accessors
    
    private func scan(action: Action) -> Input {
        switch action {
        case .insert(let character):
            return insert(character: character)
        case .remove:
            return removeIndexed()
        }
    }
    
    /// Removes the last indexed character from the cached value
    private func removeIndexed() -> Input {
        let lastInput = inputRelay.value
        let lastValue = lastInput.string

        /// input is `` or `0` -> just return previous value
        guard !lastValue.isEmpty && lastValue != Constant.zero else {
            return lastInput
        }
        
        /// input is a single digit -> just return `0`
        guard lastValue.count > 1 else {
            return .zero
        }

        var newValue = lastValue
        
        let range = newValue.range(
            startingAt: lastInput.caretIndex - 1,
            length: newValue.count - lastInput.caretIndex + 1
        )!
        newValue.removeSubrange(range)
        let caretIndex = lastInput.caretIndex - 1

        padRhsIfNeeded(value: &newValue)
        
        return Input(string: newValue, caretIndex: caretIndex)
    }
    
    /// Inserts a new character into the cached value
    /// Steps:
    /// 1. Validates the new character
    /// 2. Validates empty string
    /// 3. Inserts the new character at the position the caret points to
    /// 4. Pads the RHS if needed.
    /// 5. Validate the maximum length of values before and after the separator
    private func insert(character: Character) -> Input {
        
        ////////////////////////////////////////////////
        /// **Character validation**
        /// Validate digit or decimal-separator

        let lastInput = inputRelay.value
        
        guard Constant.allowedCharacters.contains(character) else {
            return lastInput
        }
                
        ////////////////////////////////////////////////
        /// **Empty Input Validation**
        /// All possible cases of an empty input, where
        /// nothing should actually be changed
        
        let lastValue = lastInput.string

        /// Current character is `.` and the string so far already contains `.`
        if lastValue.contains(Constant.decimalSeparator) &&
           character == Constant.decimalSeparatorChar {
            /// `12.30` + `.` = `12.30`
            return lastInput
        } else if (lastValue == Constant.zero || lastValue.isEmpty) &&
                  (character == Constant.zeroChar || character == Constant.decimalSeparatorChar) {
            /// `0` + `0` = `0`
            /// `0` + `.` = `0`
            /// `` + `0` = `0`
            /// `` + `.` = `0`
            return Input(string: Constant.zero, caretIndex: 0)
        }
        
        ////////////////////////////////////////////////
        /// **String Replacement**
        /// Append or replace a new character `[0-9\.]` depending on
        /// where the caret index points to.

        var newValue: String
        
        /// If the caret value is located at the end of the string,
        /// then just append `newCharacter` to `lastValue`
        if lastInput.caretIndex == lastValue.count {
            newValue = lastValue + "\(character)"
        } else {
            /// If the caret index is within the string,
            /// then replace the character which `lastInput.caretIndex` points to
            newValue = lastValue
            let range = Range(NSRange(location: lastInput.caretIndex, length: 1), in: newValue)!
            newValue.replaceSubrange(range, with: "\(character)")
        }
        
        /// Increment the caret index
        let newCaretIndex = lastInput.caretIndex + 1
        
        /// **RHS Padding (if needed) **
        /// We should pad the RHS component if its length is less than `maxFractionDigits`
        
        /// Separate the compound input into two components if possible: `[LHS, RHS]`
        padRhsIfNeeded(value: &newValue)
        
        ////////////////////////////////////////////////
        /// **Max Length Validation**
        /// If the input so far contains `.`.
        /// That would place the current digit to the right of the floating point.
        /// Therefore we would like to verify that there are no more than `maxFractionDigits` digits
        /// in the RHS number component.
        
        /// Re-separate `newValue` to components is it has possibly changed
        /// by a newly added padding
        let components = newValue.components(separatedBy: Constant.decimalSeparator)
        
        // Reached maximum number of digits before decimal separator
        guard components[0].count <= maxIntegerDigits else {
            return Input(string: lastValue)
        }
        
        // Reached maximum number of digits after the decimal separator
        if components.count == 2 {
            let rhs = components[1]
            if rhs.count != maxFractionDigits {
                return Input(string: lastValue)
            }
        }
        
        return Input(string: newValue, caretIndex: newCaretIndex)
    }
    
    private func padRhsIfNeeded(value: inout String) {
        let components = value.components(separatedBy: Constant.decimalSeparator)
        guard components.count == 2 else {
            return
        }
        
        let rhs = components[1]
        if rhs.isEmpty {
            value.append(Constant.doubleZero)
        } else if rhs.count == 1 {
            value.append(Constant.zero)
        }
    }
}
