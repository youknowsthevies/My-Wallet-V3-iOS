//
//  CardActivationClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol CardActivationClientAPI: class {
    func activateCard(by id: String,
                      url: String) -> Single<ActivateCardResponse.Partner>
}
