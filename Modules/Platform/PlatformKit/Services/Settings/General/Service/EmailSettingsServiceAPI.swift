// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol EmailSettingsServiceAPI: class {
    
    /// A `Single` that streams
    var email: Single<String> { get }
    
    /// Updates the email associated with the wallet
    /// - Parameter email: The new email address
    /// - Parameter context: The context in which the request has happened
    /// - Returns: A `Completable`
    func update(email: String, context: FlowContext?) -> Completable
}
