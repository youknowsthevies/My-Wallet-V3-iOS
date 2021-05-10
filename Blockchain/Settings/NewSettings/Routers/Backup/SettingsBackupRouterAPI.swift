// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

protocol SettingsBackupRouterAPI: AnyObject {
    var completionRelay: PublishRelay<Void> { get }
    func start()
}
