//
//  AnyActivityItemEventDetailsFetcher.swift
//  PlatformKit
//
//  Created by Alex McGregor on 6/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

public struct AnyActivityItemEventDetailsFetcher<Model> {

    private let detailsObservable: (String) -> Observable<Model>

    public init<API: ActivityItemEventDetailsFetcherAPI>(api: API) where API.Model == Model {
        detailsObservable = api.details
    }

    public func details(for identifier: String) -> Observable<Model> {
        detailsObservable(identifier)
    }
}
