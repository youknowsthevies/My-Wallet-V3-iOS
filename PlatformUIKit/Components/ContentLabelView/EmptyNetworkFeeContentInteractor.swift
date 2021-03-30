//
//  EmptyNetworkFeeContentInteractor.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 3/17/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift
import ToolKit

public final class EmptyNetworkFeeContentInteractor: ContentLabelViewInteractorAPI {
    public var contentCalculationState: Observable<ValueCalculationState<String>> {
        .just(.calculating)
    }
}
