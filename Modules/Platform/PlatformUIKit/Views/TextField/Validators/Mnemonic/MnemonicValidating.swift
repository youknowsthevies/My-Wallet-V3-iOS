// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol MnemonicValidating: TextValidating {
    var score: Observable<MnemonicValidationScore> { get }
}
