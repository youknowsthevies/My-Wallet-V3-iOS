//
//  SearchController.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 02/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

public final class SearchController: UISearchController {
    
    public var text: Observable<String> {
        relay.asObservable()
    }
    
    private let relay = PublishRelay<String>()
    
    public init(placeholderText: String) {
        super.init(nibName: nil, bundle: nil)
        searchResultsUpdater = self
        searchBar.placeholder = placeholderText
        searchBar.showsCancelButton = false
        searchBar.tintColor = .descriptionText
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        relay.accept(searchController.searchBar.text ?? "")
    }
}
