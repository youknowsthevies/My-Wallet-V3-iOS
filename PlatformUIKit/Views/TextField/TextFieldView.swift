//
//  TextFieldView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay
import RxCocoa

/// A styled text field component with validation and password expression scoring
public class TextFieldView: UIView {

    /// Equals to the expression: `textField.text ?? ""`
    var text: String {
        return textField.text ?? ""
    }
    
    /// Returns a boolean indicating whether the field is currently focused
    var isTextFieldFocused: Bool {
        return textField.isFirstResponder
    }
    
    // MARK: - UI Properties
    
    @IBOutlet var textField: UITextField!
    @IBOutlet private(set) var separatorView: UIView!
    @IBOutlet fileprivate var gestureMessageLabel: UILabel!
    @IBOutlet private(set) var accessoryView: UIView!
    @IBOutlet private(set) var accessoryViewWidthConstraint: NSLayoutConstraint!
    
    private weak var hintHeightConstraint: NSLayoutConstraint!
    private var keyboardInteractionController: KeyboardInteractionController!
    
    // Mutable since we would like to make the text field
    // compatible with constructs like table/collection views
    private var disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private var viewModel: TextFieldViewModel!
    
    // MARK: - Setup
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Internal API
    
    /// Should be called once upon instantiation
    func setup() {
        fromNib(named: TextFieldView.objectName)
        separatorView.backgroundColor = .lightBorder
        textField.textAlignment = .left
        gestureMessageLabel.font = .main(.medium, 12)
        gestureMessageLabel.textColor = .destructive
        gestureMessageLabel.verticalContentHuggingPriority = .required
        gestureMessageLabel.verticalContentCompressionResistancePriority = .required
        
        /// Cleanup the sensitive data if necessary
        NotificationCenter.when(UIApplication.didEnterBackgroundNotification) { [weak textField, weak viewModel] _ in
            guard let textField = textField else { return }
            guard let viewModel = viewModel else { return }
            if viewModel.type.requiresCleanupOnBackgroundState {
                textField.text = ""
                viewModel.textFieldEdited(with: "")
            }
        }
    }
    
    // MARK: - API
    
    /// Must be called by specialized subclasses
    public func setup(viewModel: TextFieldViewModel,
                      keyboardInteractionController: KeyboardInteractionController) {
        disposeBag = DisposeBag()
        self.keyboardInteractionController = keyboardInteractionController
        self.viewModel = viewModel
        
        if let hintHeightConstraint = hintHeightConstraint {
            removeConstraint(hintHeightConstraint)
        }
        
        if viewModel.hintDisplayType == .constant {
            hintHeightConstraint = gestureMessageLabel.layout(dimension: .height, to: 16)
        }
        
        /// Set the accessibility property
        textField.accessibility = viewModel.accessibility
        
        textField.returnKeyType = viewModel.returnKeyType
        textField.inputAccessoryView = keyboardInteractionController.toolbar
        textField.autocorrectionType = viewModel.type.autocorrectionType
        textField.autocapitalizationType = viewModel.type.autocapitalizationType
        textField.font = viewModel.font
        
        /// Bind `accessoryContentType`
        viewModel.accessoryContentType
            .bind(to: rx.accessoryContentType)
            .disposed(by: disposeBag)

        /// Bind `isSecure`
        viewModel.isSecure
            .drive(textField.rx.isSecureTextEntry)
            .disposed(by: disposeBag)
        
        /// Bind `contentType`
        viewModel.contentType
            .drive(textField.rx.contentType)
            .disposed(by: disposeBag)

        /// Bind `keyboardType`
        viewModel.keyboardType
            .drive(textField.rx.keyboardType)
            .disposed(by: disposeBag)
        
        // Bind `placeholder`
        viewModel.placeholder
            .drive(textField.rx.placeholderAttributedText)
            .disposed(by: disposeBag)
        
        // Bind `textColor`
        viewModel.textColor
            .drive(textField.rx.textColor)
            .disposed(by: disposeBag)
        
        // Take only the first value emitted
        viewModel.text
            .asObservable()
            .take(1)
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.gestureMessage
            .map { $0.isVisible ? $0.message : "" }
            .drive(rx.gestureMessage)
            .disposed(by: disposeBag)

        viewModel.isEnabled
            .bind(to: textField.rx.isEnabled)
            .disposed(by: disposeBag)
        
        if viewModel.type == .newPassword || viewModel.type == .confirmNewPassword {
            textField.rx.text.orEmpty
                .bind(weak: self) { [weak viewModel] (self, text) in
                    guard !self.textField.isFirstResponder else { return }
                    viewModel?.textFieldEdited(with: text)
                }
                .disposed(by: disposeBag)
        }
        
        viewModel.focus
            .emit(onNext: { [weak self] shouldGainFocus in
                guard let self = self else { return }
                if shouldGainFocus {
                    self.textField.becomeFirstResponder()
                } else {
                    self.textField.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
    }
    
    fileprivate func showGesture(message: String) {
        UIView.transition(
            with: gestureMessageLabel,
            duration: 0.15,
            options: [.beginFromCurrentState, .transitionCrossDissolve],
            animations: {
                self.gestureMessageLabel.text = message
            },
            completion: nil)
    }
    
    fileprivate func set(accessoryContentType: TextFieldViewModel.AccessoryContentType) {
        let resetAccessoryView = { [weak self] in
            self?.accessoryView.subviews.forEach { $0.removeFromSuperview() }
        }
        
        switch accessoryContentType {
        case .empty:
            resetAccessoryView()
        case .badge(let viewModel):
            if let badgeImageView = accessoryView.subviews.first as? BadgeImageView {
                badgeImageView.viewModel = viewModel
            } else {
                resetAccessoryView()
                let badgeImageView = BadgeImageView()
                badgeImageView.viewModel = viewModel
                accessoryView.addSubview(badgeImageView)
                badgeImageView.layoutToSuperview(.leading)
                badgeImageView.layoutToSuperview(.trailing, offset: -16)
                badgeImageView.layoutToSuperview(axis: .vertical)
            }
        }
    }
}

// MARK: UITextFieldDelegate

extension TextFieldView: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        viewModel.becameFirstResponderRelay.accept(())
        return true
    }
    
    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        let input = (text as NSString).replacingCharacters(in: range, with: string)
        let operation: TextInputOperation = string.isEmpty ? .deletion : .addition
        let result = viewModel.editIfNecessary(input, operation: operation)
        switch result {
        case .formatted(to: let text):
            textField.text = text
            return false
        case .original:
            return true
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.focusRelay.accept(false)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.textFieldDidEndEditing()
    }
}

// MARK: - Rx

extension Reactive where Base: TextFieldView {
    
    fileprivate var accessoryContentType: Binder<TextFieldViewModel.AccessoryContentType> {
        Binder(base) { view, contentType in
            view.set(accessoryContentType: contentType)
        }
    }
    
    /// Binder for the error handling
    fileprivate var gestureMessage: Binder<String> {
        return Binder(base) { view, message in
            view.showGesture(message: message)
        }
    }
}
