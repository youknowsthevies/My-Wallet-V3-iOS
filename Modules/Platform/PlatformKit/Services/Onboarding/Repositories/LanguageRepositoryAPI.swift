// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol LanguageRepositoryAPI: class {
    func set(language: String) -> Completable
}
