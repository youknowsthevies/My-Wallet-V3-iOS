// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

// TODO: Create mock for this to be able to test the presenting layer
protocol AnnouncementInteracting {
    var preliminaryData: Single<AnnouncementPreliminaryData> { get }
}
