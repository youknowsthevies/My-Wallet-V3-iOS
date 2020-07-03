//
//  KYCVerifyIdentityInteractor.swift
//  Blockchain
//
//  Created by Chris Arriola on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import PlatformKit
import PlatformUIKit
import RxSwift

protocol KYCVerifyIdentityInput: class {
    func submitVerification(
        onCompleted: @escaping (() -> Void),
        onError: @escaping ((Error) -> Void)
    )
    func createCredentials(
        onSuccess: @escaping ((VeriffCredentials) -> Void),
        onError: @escaping ((Error) -> Void)
    )
    func supportedDocumentTypes(
        countryCode: String,
        onSuccess: @escaping (([KYCDocumentType]) -> Void),
        onError: @escaping ((Error) -> Void)
    )
}

class KYCVerifyIdentityInteractor {
    private let loadingViewPresenter: LoadingViewPresenting
    
    private var cache = [String: [KYCDocumentType]]()

    private let veriffService = VeriffService()

    private let client: KYCClientAPI
    private var veriffCredentials: VeriffCredentials?

    private var disposable: Disposable?

    init(client: KYCClientAPI = KYCClient(),
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared) {
        self.loadingViewPresenter = loadingViewPresenter
        self.client = client
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    private func supportedDocumentTypes(_ countryCode: String) -> Single<[KYCDocumentType]> {
        // Check cache
        if let types = cache[countryCode] {
            return Single.just(types)
        }

        return client
            .supportedDocuments(for: countryCode)
            .map { $0.documentTypes }
            .do(onSuccess: { [weak self] types in
                self?.cache[countryCode] = types
            })
    }
}

extension KYCVerifyIdentityInteractor: KYCVerifyIdentityInput {
    func submitVerification(
        onCompleted: @escaping (() -> Void),
        onError: @escaping ((Error) -> Void)
    ) {
        guard let credentials = veriffCredentials else { return }
        disposable = veriffService.submitVerification(applicantId: credentials.applicantId)
            .do(onDispose: { [weak self] in
                self?.loadingViewPresenter.hide()
            })
            .subscribe(
                onCompleted: onCompleted,
                onError: onError
            )
    }

    func createCredentials(onSuccess: @escaping ((VeriffCredentials) -> Void), onError: @escaping ((Error) -> Void)) {
        disposable = veriffService.createCredentials()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] credentials in
                guard let this = self else { return }
                this.veriffCredentials = credentials
                onSuccess(credentials)
            }, onError: onError)
    }

    func supportedDocumentTypes(countryCode: String, onSuccess: @escaping (([KYCDocumentType]) -> Void), onError: @escaping ((Error) -> Void)) {
        disposable = supportedDocumentTypes(countryCode)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: onSuccess, onError: onError)
    }
}
