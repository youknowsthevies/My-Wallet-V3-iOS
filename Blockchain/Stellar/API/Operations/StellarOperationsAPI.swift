// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift
import stellarsdk

protocol StellarOperationsAPI {
    typealias AccountID = String
    typealias PageToken = String
    
    var operations: Observable<[StellarOperation]> { get }
    func isStreaming() -> Bool
    func end()
    func clear()
}
