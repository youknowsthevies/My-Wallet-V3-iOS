//
//  CardActivationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 14/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit

public class CardActivationService: CardActivationServiceAPI {
    
    // MARK: - Types
    
    private enum Constant {
        /// Duration in seconds
        static let pollingDuration: TimeInterval = 60
    }
    
    public enum State {
        case active(CardData)
        case pending
        case inactive(CardData?)
        
        var isPending: Bool {
            switch self {
            case .pending:
                return true
            case .active, .inactive:
                return false
            }
        }
        
        init(_ cardPayload: CardPayload) {
            guard let cardData = CardData(response: cardPayload) else {
                self = .inactive(nil)
                return
            }
            switch cardPayload.state {
            case .active:
                self = .active(cardData)
            case .pending:
                self = .pending
            case .blocked, .expired, .created, .none, .fraudReview, .manualReview:
                self = .inactive(cardData)
            }
        }
    }
    
    // MARK: - Properties
    
    public var cancel: Completable {
        pollService.cancel
    }
    
    // MARK: - Injected
    
    private let pollService: PollService<State>
    private let authenticationService: NabuAuthenticationServiceAPI
    private let client: CardDetailClientAPI
    
    // MARK: - Setup
    
    public init(client: CardDetailClientAPI,
                authenticationService: NabuAuthenticationServiceAPI) {
        self.client = client
        self.authenticationService = authenticationService
        pollService = .init(matcher: { !$0.isPending })
    }
    
    public func waitForActivation(of cardId: String) -> Single<PollResult<State>> {
        pollService.setFetch(weak: self) { (self) in
            self.authenticationService
                .tokenString
                .flatMap(weak: self) { (self, token) in
                    self.client.getCard(by: cardId, token: token)
                }
                .map { payload in
                    guard payload.state != .pending else {
                        return .pending
                    }
                    return State(payload)
                }
        }
        
        return pollService.poll(timeoutAfter: Constant.pollingDuration)
    }
}
