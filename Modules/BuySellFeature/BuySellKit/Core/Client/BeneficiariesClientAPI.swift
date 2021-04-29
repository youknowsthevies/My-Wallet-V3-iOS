// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

protocol BeneficiariesClientAPI: AnyObject {
    var beneficiaries: Single<[BeneficiaryResponse]> { get }
    func deleteBank(by id: String) -> Completable
}
