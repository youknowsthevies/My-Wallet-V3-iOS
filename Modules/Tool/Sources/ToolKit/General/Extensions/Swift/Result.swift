// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol ResultProtocol {

    associatedtype Success
    associatedtype Failure: Error

    var result: Result<Success, Failure> { get }

    static func success(_ success: Success) -> Self
    static func failure(_ failure: Failure) -> Self

    func map<NewSuccess>(
        _ transform: (Success) -> NewSuccess
    ) -> Result<NewSuccess, Failure>

    func mapError<NewFailure>(
        _ transform: (Failure) -> NewFailure) -> Result<Success, NewFailure> where NewFailure: Error

    func flatMap<NewSuccess>(
        _ transform: (Success) -> Result<NewSuccess, Failure>
    ) -> Result<NewSuccess, Failure>

    func flatMapError<NewFailure>(
        _ transform: (Failure) -> Result<Success, NewFailure>
    ) -> Result<Success, NewFailure> where NewFailure: Error

    func get() throws -> Success
}

extension Result: ResultProtocol {
    public var result: Result<Success, Failure> { self }
}
