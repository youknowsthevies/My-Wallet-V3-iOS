//
//  SettingsSectionsProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

final class SettingsSectionsProvider {
    
    var states: Observable<SettingSectionsLoadingStates> {
        Observable
        .combineLatest(
            presenters[.about]!.state,
            presenters[.connect]!.state,
            presenters[.cards]!.state,
            presenters[.security]!.state,
            presenters[.profile]!.state,
            presenters[.preferences]!.state
        ) { (about: $0, connect: $1, cards: $2, security: $3, profile: $4, preferences: $5) }
        .map { states in
               SettingSectionsLoadingStates(statePerSection: [
                .about: states.about,
                .connect: states.connect,
                .cards: states.cards,
                .security: states.security,
                .profile: states.profile,
                .preferences: states.preferences
               ])
        }
        .share()
    }
    
    var sections: Observable<[SettingsSectionViewModel]> {
        states
            .map { $0.all }
            .map { $0.compactMap { $0.value } }
            .map { $0.compactMap { $0.viewModel } }
            .map { $0.sorted(by: { $0.sectionType.rawValue < $1.sectionType.rawValue }) }
        
    }
    
    private var all: [SettingsSectionPresenting] {
        Array(presenters.values)
    }
    
    private var presenters: [SettingsSectionType: SettingsSectionPresenting] = [:]
    
    init(about: SettingsSectionPresenting,
         connect: SettingsSectionPresenting,
         cards: SettingsSectionPresenting,
         security: SettingsSectionPresenting,
         profile: SettingsSectionPresenting,
         preferences: SettingsSectionPresenting) {
        presenters[.profile] = profile
        presenters[.about] = about
        presenters[.connect] = connect
        presenters[.cards] = cards
        presenters[.security] = security
        presenters[.preferences] = preferences
    }
}
