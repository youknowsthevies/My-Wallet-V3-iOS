//
//  RecoveryPhraseVerifyingAPI.swift
//  Blockchain
//
//  Created by AlexM on 2/2/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol RecoveryPhraseVerifyingServiceAPI {
    var phraseComponents: [String] { get set }
    var selection: [String] { get set }
    func markBackupVerified() -> Completable
}
