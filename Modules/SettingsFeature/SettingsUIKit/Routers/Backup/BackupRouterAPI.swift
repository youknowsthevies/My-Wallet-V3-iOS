// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public protocol BackupRouterAPI: AnyObject {
    var completionRelay: PublishRelay<Void> { get }
    
    var entry: BackupRouterEntry { get }
    
    func next(to state: BackupRouterStateService.State)
    func previous()
    func start()
}
