// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol LanguageRepositoryAPI: AnyObject {
    func set(language: String) -> Completable
}
