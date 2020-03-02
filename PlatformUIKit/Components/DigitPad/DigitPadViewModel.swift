//
//  DigitPadViewModel.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

/// TODO: Modularize to play nicer with different flows.
/// At the moment all the logic is centralized in the view model - there should be
/// another object to take up responsibility for logic.
public final class DigitPadViewModel {
    
    // MARK: - Types
    
    public enum PadType {
        case pin(maxCount: Int)
        case number
    }
    
    // MARK: - Properties
    
    /// The digits sorted by index (i.e 0 index represents zero-digit, 5 index represents the fifth digit)
    public let digitButtonViewModelArray: [DigitPadButtonViewModel]
    
    /// Backspace button
    public let backspaceButtonViewModel: DigitPadButtonViewModel
    
    /// Custom button, is located on the bottom-left side of the pad
    public let customButtonViewModel: DigitPadButtonViewModel
    
    /// Relay for bottom leading button taps
    private let customButtonTapRelay = PublishRelay<Void>()
    public var customButtonTapObservable: Observable<Void> {
        return customButtonTapRelay.asObservable()
    }
    
    /// Tap observable for the backspace button
    public var backspaceButtonTapObservable: Observable<Void> {
        return backspaceButtonViewModel.tapObservable
            .map { _ -> Void in return () }
    }
    
    /// Relay for pin value. subscribe to it to get the pin stream
    public let valueRelay = BehaviorRelay<String>(value: "")
    public var valueObservable: Observable<String> {
        return valueRelay.asObservable()
    }
    
    /// Observes the current length of the value
    public let valueLengthObservable: Observable<Int>
    
    /// Relay for tapping
    private let valueInsertedPublishRelay = PublishRelay<Void>()
    public var valueInsertedObservable: Observable<Void> {
        return valueInsertedPublishRelay.asObservable()
    }
    
    /// The raw `String` value
    public var value: String {
        return valueRelay.value
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(padType: PadType,
                customButtonViewModel: DigitPadButtonViewModel = .empty,
                contentTint: UIColor = .black,
                buttonHighlightColor: UIColor = .clear) {

        let buttonBackground = DigitPadButtonViewModel.Background(highlightColor: buttonHighlightColor)
        
        // Initialize all buttons
        digitButtonViewModelArray = (0...9).map {
            return DigitPadButtonViewModel(content: .label(text: "\($0)", tint: contentTint), background: buttonBackground)
        }

        backspaceButtonViewModel = DigitPadButtonViewModel(
            content: .image(type: .backspace, tint: contentTint),
            background: buttonBackground
        )
        self.customButtonViewModel = customButtonViewModel
        
        // Digit count of the value
        valueLengthObservable = valueRelay.map { $0.count }.share(replay: 1)
        
        // Bind backspace to an action
        backspaceButtonViewModel.tapObservable
            .bind { [unowned self] _ in
                switch padType {
                case .pin:
                    let value = String(self.valueRelay.value.dropLast())
                    self.valueRelay.accept(value)
                case .number:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        // Bind taps on the bottom left view to an action
        customButtonViewModel.tapObservable
            .map { _ in Void() }
            .bind(to: customButtonTapRelay)
            .disposed(by: disposeBag)

        // Merge all digit observables into one stream of digits
        let buttons: [DigitPadButtonViewModel]
        switch padType {
        case .number:
            buttons = digitButtonViewModelArray + [customButtonViewModel]
        case .pin:
            buttons = digitButtonViewModelArray
        }
        let tapObservable = Observable.merge(buttons.map { $0.tapObservable })

        tapObservable
            .bind { [unowned self] content in
                switch content {
                case .label(text: let digit, tint: _):
                    switch padType {
                    case .number:
                        self.valueRelay.accept(digit)
                        self.valueInsertedPublishRelay.accept(Void())
                    case .pin(maxCount: let count):
                        let value = "\(self.value)\(digit)"
                        if self.value.count < count {
                            self.valueRelay.accept(value)
                        }
                        if self.value.count == count {
                            self.valueInsertedPublishRelay.accept(Void())
                        }
                    }
                case .label, .image, .none:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
    
    /// Resets the pin to a given value
    public func reset(to value: String = "") {
        valueRelay.accept(value)
        valueInsertedPublishRelay.accept(Void())
    }
}

