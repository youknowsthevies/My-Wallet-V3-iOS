//
//  TextFieldViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import ToolKit
import Localization

/// A view model for text field
public class TextFieldViewModel {
    
    // MARK: - Type
    
    private typealias LocalizedString = LocalizationConstants.TextField
        
    struct GestureMessage: Equatable {
        let message: String
        let isVisible: Bool
    }
    
    public enum HintDisplayType {
        
        /// Varies in height
        case dynamic
        
        /// Has constant height
        case constant
    }
    
    /// The trailing accessory view.
    /// Can potentially support, images, labels and even custom views
    public enum AccessoryContentType: Equatable {
        
        /// Image accessory view
        case badge(BadgeImageViewModel)
        
        /// Empty accessory view
        case empty
    }
    
    // MARK: Properties

    /// The state of the text field
    public var state: Observable<State> {
        stateRelay.asObservable()
    }
    
    /// Should text field gain focus or remove
    public let focusRelay = PublishRelay<Bool>()
    
    public var isHintVisible: Observable<Bool> {
        isHintVisibleRelay.asObservable()
    }
    
    var becameFirstResponder: Observable<Void> {
        becameFirstResponderRelay.asObservable()
    }
    
    let becameFirstResponderRelay = PublishRelay<Void>()
    
    /// The content type of the `UITextField`
    var contentType: Driver<UITextContentType?> {
        contentTypeRelay
            .asDriver()
            .distinctUntilChanged()
    }
    
    /// The keyboard type of the `UITextField`
    var keyboardType: Driver<UIKeyboardType> {
        keyboardTypeRelay
            .asDriver()
            .distinctUntilChanged()
    }
    
    /// The isSecureTextEntry of the `UITextField`
    var isSecure: Driver<Bool> {
        isSecureRelay
            .asDriver()
            .distinctUntilChanged()
    }
    
    /// The placeholder of the text-field
    var placeholder: Driver<NSAttributedString> {
        placeholderRelay.asDriver()
    }
    
    /// The color of the content (.mutedText, .textFieldText)
    var textColor: Driver<UIColor> {
        textColorRelay.asDriver()
    }
        
    /// A text to display below the text field in case of an error
    var gestureMessage: Driver<GestureMessage> {
        Driver
            .combineLatest(
                hintRelay.asDriver(),
                isHintVisibleRelay.asDriver()
            )
            .map {
                GestureMessage(
                    message: $0.0,
                    isVisible: $0.1
                )
            }
            .distinctUntilChanged()
    }
    
    public let isEnabledRelay = BehaviorRelay<Bool>(value: true)
    var isEnabled: Observable<Bool> {
        isEnabledRelay.asObservable()
    }
    
    var autocapitalizationType: Observable<UITextAutocapitalizationType> {
        autocapitalizationTypeRelay.asObservable()
    }
                
    /// A relay for accessory content type
    let accessoryContentTypeRelay = BehaviorRelay<AccessoryContentType>(value: .empty)
    var accessoryContentType: Observable<AccessoryContentType> {
        accessoryContentTypeRelay
            .distinctUntilChanged()
    }
    
    /// The content of the text field
    public let textRelay = BehaviorRelay<String>(value: "")
    var text: Observable<String> {
        textRelay
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .distinctUntilChanged()
    }
        
    let isHintVisibleRelay = BehaviorRelay(value: false)
    
    let font = UIFont.mainMedium(16)
    
    private let autocapitalizationTypeRelay: BehaviorRelay<UITextAutocapitalizationType>
    private let keyboardTypeRelay: BehaviorRelay<UIKeyboardType>
    private let contentTypeRelay: BehaviorRelay<UITextContentType?>
    private let isSecureRelay = BehaviorRelay(value: false)
    private let placeholderRelay: BehaviorRelay<NSAttributedString>
    private let textColorRelay = BehaviorRelay<UIColor>(value: .textFieldText)
    private let hintRelay = BehaviorRelay<String>(value: "")
    private let stateRelay = BehaviorRelay<State>(value: .empty)
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    let validator: TextValidating
    let formatter: TextFormatting
    let textMatcher: TextMatchValidatorAPI?
    let hintDisplayType: HintDisplayType
    let type: TextFieldType
    let accessibility: Accessibility
    let messageRecorder: MessageRecording
    
    // MARK: - Setup
    
    public init(with type: TextFieldType,
                hintDisplayType: HintDisplayType = .dynamic,
                validator: TextValidating,
                formatter: TextFormatting = TextFormatterFactory.alwaysCorrect,
                textMatcher: TextMatchValidatorAPI? = nil,
                messageRecorder: MessageRecording) {
        self.messageRecorder = messageRecorder
        self.formatter = formatter
        self.validator = validator
        self.textMatcher = textMatcher
        self.type = type
        self.hintDisplayType = hintDisplayType
        
        let placeholder = NSAttributedString(
            string: type.placeholder,
            attributes: [
                .foregroundColor: UIColor.textFieldPlaceholder,
                .font: font
            ]
        )
        autocapitalizationTypeRelay = BehaviorRelay(value: type.autocapitalizationType)
        placeholderRelay = BehaviorRelay(value: placeholder)
        keyboardTypeRelay = BehaviorRelay(value: type.keyboardType)
        contentTypeRelay = BehaviorRelay(value: type.contentType)
        isSecureRelay.accept(type.isSecure)
        accessibility = type.accessibility

        text
            .bind(to: validator.valueRelay)
            .disposed(by: disposeBag)
        
        let matchState: Observable<TextValidationState>
        if let textMatcher = textMatcher {
            matchState = textMatcher.validationState
        } else {
            matchState = .just(.valid)
        }
                
        Observable
            .combineLatest(matchState, validator.validationState, text.asObservable())
            .map { (matchState, validationState, text) in
                State(matchState: matchState, validationState: validationState, text: text)
            }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
        
        self.state
            .map { $0.hint ?? "" }
            .bind(to: hintRelay)
            .disposed(by: disposeBag)
    }
    
    func textFieldDidEndEditing() {
        isHintVisibleRelay.accept(true)
    }
        
    /// Should be called upon editing the text field
    func textFieldEdited(with value: String) {
        messageRecorder.record("Text field \(type.debugDescription) edited")
        textRelay.accept(value)
        isHintVisibleRelay.accept(type.showsHintWhileTyping)
    }
    
    func editIfNecessary(_ text: String, operation: TextInputOperation) -> TextFormattingSource {
        let processResult = formatter.format(text, operation: operation)
        switch processResult {
        case .formatted(to: let processedText), .original(text: let processedText):
            textFieldEdited(with: processedText)
        }
        return processResult
    }
}

// MARK: - State

extension TextFieldViewModel {
    
    /// A state of a single text field
    public enum State {
        
        /// Valid state - validation is passing
        case valid(value: String)
        
        /// Empty field
        case empty
        
        /// Mismatch error
        case mismatch(reason: String?)
        
        /// Invalid state - validation is not passing.
        case invalid(reason: String?)
    
        var hint: String? {
            switch self {
            case .invalid(reason: let reason), .mismatch(reason: let reason):
                return reason
            default:
                return nil
            }
        }

        var isInvalid: Bool {
            switch self {
            case .invalid:
                return true
            default:
                return false
            }
        }
        
        var isMismatch: Bool {
            switch self {
            case .mismatch:
                return true
            default:
                return false
            }
        }
        
        /// Returns the text value if there is a valid value
        public var value: String? {
            switch self {
            case .valid(value: let value):
                return value
            default:
                return nil
            }
        }
                
        /// Returns whether or not the currenty entry is valid
        public var isValid: Bool {
            switch self {
            case .valid:
                return true
            default:
                return false
            }
        }
        
        /// Reducer for possible validation states
        init(matchState: TextValidationState, validationState: TextValidationState, text: String) {
            guard !text.isEmpty else {
                self = .empty
                return
            }
            switch (matchState, validationState, text) {
            case (.valid, .valid, let text):
                self = .valid(value: text)
            case (.invalid(reason: let reason), _, text):
                self = .mismatch(reason: reason)
            case (_, .invalid(reason: let reason), _):
                self = .invalid(reason: reason)
            default:
                self = .invalid(reason: nil)
            }
        }
    }
}

// MARK: - Equatable (Lossy - only the state, without associated values)

extension TextFieldViewModel.State: Equatable {
    public static func == (lhs: TextFieldViewModel.State,
                           rhs: TextFieldViewModel.State) -> Bool {
        switch (lhs, rhs) {
        case (.valid, .valid),
             (.mismatch, .mismatch),
             (.invalid, .invalid),
             (.empty, .empty):
            return true
        default:
            return false
        }
    }
}
