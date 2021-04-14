//
//  DIKit.swift
//  NetworkKit
//
//  Created by Jack Pooley on 23/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import ToolKit

public enum DIKitContext: String {
    case network
    case explorer
    case wallet
    case retail
    case everypay
}

extension DependencyContainer {
    
    // MARK: - NetworkKit Module
     
    public static var networkKit = module {
        
        factory { BlockchainAPI.shared }
        
        factory { UserAgentProvider() }
        
        single { CertificatePinner() as CertificatePinnerAPI }
        
        single { SessionDelegate() as SessionDelegateAPI }
        
        single { URLSessionConfiguration.defaultConfiguration() }
        
        single { URLSession.defaultSession() }
        
        single { BlockchainNetworkCommunicatorSessionHandler() as NetworkSessionDelegateAPI }
        
        single { Network.Config.defaultConfig }
        
        factory { () -> APICode in
            let config: Network.Config = DIKit.resolve()
            return config.apiCode as APICode
        }
        
        single { NetworkResponseDecoder() as NetworkResponseDecoderAPI }
        
        single { RequestBuilder() }
        
        single { NetworkCommunicator.defaultCommunicator() as NetworkCommunicatorAPI }
        
        single(tag: DIKitContext.network) { ConcurrentDispatchQueueScheduler(qos: .background) }
        
        // MARK: - Explorer
        
        single(tag: DIKitContext.explorer) { RequestBuilder(networkConfig: Network.Config.explorerConfig) }
        
        single(tag: DIKitContext.explorer) { NetworkCommunicator() as NetworkCommunicatorAPI }
        
        // MARK: - Wallet
        
        single(tag: DIKitContext.wallet) { RequestBuilder(networkConfig: Network.Config.walletConfig) }
        
        single(tag: DIKitContext.wallet) { NetworkCommunicator() as NetworkCommunicatorAPI }
        
        // MARK: - Retail
        
        single(tag: DIKitContext.retail) { RequestBuilder(networkConfig: Network.Config.retailConfig) }
        
        single(tag: DIKitContext.retail) { NetworkCommunicator.retailCommunicator() as NetworkCommunicatorAPI }
        
        // MARK: - EveryPay
        
        single(tag: DIKitContext.everypay) { DefaultSessionHandler() as NetworkSessionDelegateAPI }
        
        single(tag: DIKitContext.everypay) { RequestBuilder(networkConfig: Network.Config.everypayConfig) }
        
        single(tag: DIKitContext.everypay) { NetworkCommunicator.everypayCommunicator() as NetworkCommunicatorAPI }
        
        // MARK: - NEW Networking
        
        single { NetworkResponseHandler() as NetworkResponseHandlerAPI }
        
        single { NetworkAdapter.defaultAdapter() as NetworkAdapterAPI }
        
        single { NetworkCommunicatorNew.defaultCommunicator() as NetworkCommunicatorNewAPI }
        
        // MARK: - NEW Networking - Wallet
        
        single(tag: DIKitContext.wallet) { NetworkAdapter() as NetworkAdapterAPI }
        
        // MARK: - NEW Networking - Retail
        
        single(tag: DIKitContext.retail) { NetworkAdapter.retailAdapter() as NetworkAdapterAPI }

        single(tag: DIKitContext.retail) { NetworkCommunicatorNew.retailCommunicator() as NetworkCommunicatorNewAPI }
        
        // MARK: - NEW Networking - EveryPay
        
        single(tag: DIKitContext.everypay) { NetworkAdapter.everypayAdapter() as NetworkAdapterAPI }
        
        single(tag: DIKitContext.everypay) { NetworkCommunicatorNew.everypayCommunicator() as NetworkCommunicatorNewAPI }
        
        // MARK: - NEW Networking - Other
        
        single { () -> NetworkSession in
            let session: URLSession = DIKit.resolve()
            return session as NetworkSession
        }
    }
}

extension NetworkCommunicator {
    
    fileprivate static func defaultCommunicator(
        eventRecorder: AnalyticsEventRecording = resolve()
    ) -> NetworkCommunicator {
        NetworkCommunicator(eventRecorder: eventRecorder)
    }
    
    fileprivate static func retailCommunicator(
        authenticator: AuthenticatorAPI = resolve()
    ) -> NetworkCommunicator {
        NetworkCommunicator(authenticator: authenticator)
    }
    
    fileprivate static func everypayCommunicator(
        sessionHandler: NetworkSessionDelegateAPI = resolve(tag: DIKitContext.everypay)
    ) -> NetworkCommunicator {
        NetworkCommunicator(sessionHandler: sessionHandler)
    }
}

extension NetworkCommunicatorNew {
    
    fileprivate static func defaultCommunicator(
        eventRecorder: AnalyticsEventRecording = resolve()
    ) -> NetworkCommunicatorNew {
        NetworkCommunicatorNew(eventRecorder: eventRecorder)
    }
    
    fileprivate static func retailCommunicator(
        authenticator: AuthenticatorNewAPI = resolve()
    ) -> NetworkCommunicatorNew {
        NetworkCommunicatorNew(authenticator: authenticator)
    }
    
    fileprivate static func everypayCommunicator(
        sessionHandler: NetworkSessionDelegateAPI = resolve(tag: DIKitContext.everypay)
    ) -> NetworkCommunicatorNew {
        NetworkCommunicatorNew(sessionHandler: sessionHandler)
    }
}

extension NetworkAdapter {
    
    fileprivate static func defaultAdapter(
        communicator: NetworkCommunicatorNewAPI = resolve()
    ) -> NetworkAdapter {
        NetworkAdapter(communicator: communicator)
    }
    
    fileprivate static func retailAdapter(
        communicator: NetworkCommunicatorNewAPI = resolve(tag: DIKitContext.retail)
    ) -> NetworkAdapter {
        NetworkAdapter(communicator: communicator)
    }
    
    fileprivate static func everypayAdapter(
        communicator: NetworkCommunicatorNewAPI = resolve(tag: DIKitContext.everypay)
    ) -> NetworkAdapter {
        NetworkAdapter(communicator: communicator)
    }
}

extension URLSession {
    
    fileprivate static func defaultSession(
        with configuration: URLSessionConfiguration = resolve(),
        sessionDelegate delegate: SessionDelegateAPI = resolve(),
        delegateQueue queue: OperationQueue? = nil
    ) -> URLSession {
        URLSession(configuration: configuration, delegate: delegate, delegateQueue: queue)
    }
}

extension URLSessionConfiguration {
    
    fileprivate static func defaultConfiguration(
        userAgentProvider: UserAgentProvider = resolve()
    ) -> URLSessionConfiguration {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = [
            HttpHeaderField.userAgent: userAgentProvider.userAgent!
        ]
        sessionConfiguration.waitsForConnectivity = true
        sessionConfiguration.timeoutIntervalForResource = 300
        return sessionConfiguration
    }
}

@available(*, deprecated, message: "Don't use this. If you're reaching for this you're doing something wrong.")
@objc public class NetworkDependenciesObjc: NSObject {
    
    @Inject @objc public static var certificatePinner: CertificatePinnerAPI
    
    @Inject @objc public static var session: URLSession
}
