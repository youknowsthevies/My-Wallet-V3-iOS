//
//  ReactiveWallet.swift
//  PlatformKit
//
//  Created by Jack Pooley on 30/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import RxRelay
import RxSwift

/// An extension to `Wallet` which makes wallet functionality Rx friendly.
public final class ReactiveWallet: ReactiveWalletAPI {
    
    // MARK: - Types
    
    private enum WalletAndMetadataState {
        
        struct PartialState {
            let walletInitialized: Bool
            let metadataLoaded: Bool
            
            init(walletInitialized: Bool = false, metadataLoaded: Bool = false) {
                self.walletInitialized = walletInitialized
                self.metadataLoaded = metadataLoaded
            }
        }
        
        case uninitialized
        case partiallyInitialised(PartialState)
        case initialized
        
        var isInitialized: Bool {
            guard case .initialized = self else {
                return false
            }
            return true
        }
        
        mutating func setWalletInitialised() -> Bool {
            switch self {
            case .uninitialized:
                self = .partiallyInitialised(.init(walletInitialized: true))
            case .partiallyInitialised(let state) where state.metadataLoaded:
                self = .initialized
                return true
            default:
                break
            }
            return false
        }
        
        mutating func setMetadataLoaded() -> Bool {
            switch self {
            case .uninitialized:
                self = .partiallyInitialised(.init(walletInitialized: true))
            case .partiallyInitialised(let state) where state.walletInitialized:
                self = .initialized
                return true
            default:
                break
            }
            return false
        }
        
        mutating func setUninitialized() {
            self = .uninitialized
        }
    }
    
    // MARK: - Public properties

    public var waitUntilInitialized: Observable<Void> {
        waitUntilInitializedObservable
            .share(replay: 1, scope: .whileConnected)
    }

    public var waitUntilInitializedSingle: Single<Void> {
        waitUntilInitializedObservable
            .take(1)
            .asSingle()
    }
    
    /// A `Single` that streams a boolean element indicating
    /// whether the wallet is initialized
    public var initializationState: Single<WalletSetup.State> {
        state.take(1).asSingle()
    }
    
    // MARK: - Private properties
    
    private var waitUntilInitializedObservable: Observable<Void> {
        state
            .asObservable()
            .filter { state -> Bool in
                state == .initialized
            }
            .mapToVoid()
    }
    
    private let state = BehaviorRelay<WalletSetup.State>(value: .uninitialized)
    
    private let walletAndMetadataState = Atomic<WalletAndMetadataState>(.uninitialized)
    
    // MARK: - Init
    
    init() {
        NotificationCenter.when(.walletInitialized) { [weak self] _ in
            guard let self = self else { return }
            
            self.walletAndMetadataState.mutate { state in
                if state.setWalletInitialised() {
                    self.setInitialized()
                }
            }
        }
        
        NotificationCenter.when(.walletMetadataLoaded) { [weak self] _ in
            guard let self = self else { return }

            self.walletAndMetadataState.mutate { state in
                if state.setMetadataLoaded() {
                    self.setInitialized()
                }
            }
        }
        
        NotificationCenter.when(.logout) { [weak self] _ in
            self?.resetState()
        }
    }
    
    // MARK: - Private methods
    
    private func setInitialized() {
        state.accept(.initialized)
    }
    
    private func resetState() {
        walletAndMetadataState.mutate { $0.setUninitialized() }
        state.accept(.uninitialized)
    }
}
