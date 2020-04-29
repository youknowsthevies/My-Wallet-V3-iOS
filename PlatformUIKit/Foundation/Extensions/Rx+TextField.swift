//
//  Rx+TextField.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: UITextField {
    /// Bindable for `isSecureTextEntry` property
    public var isSecureTextEntry: Binder<Bool> {
        return Binder(self.base) { textField, isSecureTextEntry in
            textField.isSecureTextEntry = isSecureTextEntry
        }
    }
    
    /// Bindable for `textContentType` property
    public var contentType: Binder<UITextContentType?> {
        return Binder(self.base) { textField, contentType in
            textField.textContentType = contentType
        }
    }
    
    /// Bindable for `keyboardType` property
    public var keyboardType: Binder<UIKeyboardType> {
        return Binder(self.base) { textField, keyboardType in
            textField.keyboardType = keyboardType
        }
    }
    
    /// Bindable for `returnKeyType` property
    public var returnKeyType: Binder<UIReturnKeyType> {
        return Binder(self.base) { textField, returnKeyType in
            textField.returnKeyType = returnKeyType
        }
    }
    
    /// Bindable for `autocapitalizationType` property
    public var autocapitalizationType: Binder<UITextAutocapitalizationType> {
        return Binder(self.base) { textField, autocapitalizationType in
            textField.autocapitalizationType = autocapitalizationType
        }
    }
    
    /// Bindable for `placeholderAttributedText` property
    public var placeholderAttributedText: Binder<NSAttributedString?> {
        return Binder(self.base) { textField, placeholder in
            textField.attributedPlaceholder = placeholder
        }
    }
    
    /// Bindable for `textColor` property
    public var textColor: Binder<UIColor> {
        return Binder(self.base) { textField, textColor in
            textField.textColor = textColor
        }
    }
}

