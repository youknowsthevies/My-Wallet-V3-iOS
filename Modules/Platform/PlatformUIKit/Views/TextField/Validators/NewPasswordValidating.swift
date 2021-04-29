// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol NewPasswordValidating: TextValidating {
    var score: Observable<PasswordValidationScore> { get }
}
