//
//  TextMatchValidatorAPI.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 24/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol TextMatchValidatorAPI: class {
    var validationState: Observable<TextValidationState> { get }
}
