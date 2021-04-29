// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol TextMatchValidatorAPI: class {
    var validationState: Observable<TextValidationState> { get }
}
