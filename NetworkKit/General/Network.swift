//
//  Network.swift
//  PlatformKit
//
//  Created by Jack on 22/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import ToolKit

@available(*, deprecated, message: "Don't use this. If you're reaching for this you're doing something wrong.")
@objc public class NetworkDependenciesObjc: NSObject {
    @objc public let session: URLSession = Network.Dependencies.default.session
    
    public static let shared = NetworkDependenciesObjc()
    
    @objc public class func sharedInstance() -> NetworkDependenciesObjc {
        NetworkDependenciesObjc.shared
    }
}

public struct Network {
    
    public struct Config {
                
        public let apiScheme: String
        public let apiHost: String
        public let apiCode: String
        public let pathComponents: [String]

        public static let defaultConfig: Config = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.apiHost,
            apiCode: BlockchainAPI.Parameters.apiCode,
            pathComponents: []
        )
        
        public static let retailConfig: Config = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.apiHost,
            apiCode: BlockchainAPI.Parameters.apiCode,
            pathComponents: ["nabu-gateway"]
        )
        
        public static let explorerConfig: Config = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.explorerHost,
            apiCode: BlockchainAPI.Parameters.apiCode,
            pathComponents: []
        )
        
        public static let walletConfig: Config = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.walletHost,
            apiCode: BlockchainAPI.Parameters.apiCode,
            pathComponents: []
        )
        
        public static let everypayConfig = Config(
            apiScheme: "https",
            apiHost: BlockchainAPI.shared.everyPayHost,
            apiCode: "",
            pathComponents: []
        )
    }
    
    public struct Dependencies {
        // TODO:
        // * This should be private, public until we can re-write our old network code
        public let blockchainAPIConfig: Config
        public let session: URLSession
        public let requestBuilder: RequestBuilder
        
        let sessionConfiguration: URLSessionConfiguration
        let sessionDelegate: SessionDelegateAPI
        
        public let communicator: NetworkCommunicatorAPI & AnalyticsEventRecordable
        
        public static let `default`: Dependencies = {
            let blockchainAPIConfig = Config.defaultConfig
            let sessionConfiguration = URLSessionConfiguration.default
            if let userAgent = UserAgentProvider.shared.userAgent {
                sessionConfiguration.httpAdditionalHeaders = [HttpHeaderField.userAgent: userAgent]
            }
            sessionConfiguration.waitsForConnectivity = true
            let sessionDelegate = SessionDelegate()
            let session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
            let communicator = NetworkCommunicator(session: session, sessionDelegate: sessionDelegate)
            let requestBuilder = RequestBuilder(networkConfig: blockchainAPIConfig)
            return Dependencies(
                blockchainAPIConfig: blockchainAPIConfig,
                session: session,
                requestBuilder: requestBuilder,
                sessionConfiguration: sessionConfiguration,
                sessionDelegate: sessionDelegate,
                communicator: communicator
            )
        }()
        
        public static let explorer: Dependencies = {
            let blockchainAPIConfig = Config.explorerConfig
            let sessionConfiguration = URLSessionConfiguration.default
            if let userAgent = UserAgentProvider.shared.userAgent {
                sessionConfiguration.httpAdditionalHeaders = [HttpHeaderField.userAgent: userAgent]
            }
            sessionConfiguration.waitsForConnectivity = true
            let sessionDelegate = SessionDelegate()
            let session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
            let communicator = NetworkCommunicator(session: session, sessionDelegate: sessionDelegate)
            let requestBuilder = RequestBuilder(networkConfig: blockchainAPIConfig)
            return Dependencies(
                blockchainAPIConfig: blockchainAPIConfig,
                session: session,
                requestBuilder: requestBuilder,
                sessionConfiguration: sessionConfiguration,
                sessionDelegate: sessionDelegate,
                communicator: communicator
            )
        }()
        
        public static let wallet: Dependencies = {
            let blockchainAPIConfig = Config.walletConfig
            let sessionConfiguration = URLSessionConfiguration.default
            if let userAgent = UserAgentProvider.shared.userAgent {
                sessionConfiguration.httpAdditionalHeaders = [HttpHeaderField.userAgent: userAgent]
            }
            sessionConfiguration.waitsForConnectivity = true
            let sessionDelegate = SessionDelegate()
            let session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
            let communicator = NetworkCommunicator(session: session, sessionDelegate: sessionDelegate)
            let requestBuilder = RequestBuilder(networkConfig: blockchainAPIConfig)
            return Dependencies(
                blockchainAPIConfig: blockchainAPIConfig,
                session: session,
                requestBuilder: requestBuilder,
                sessionConfiguration: sessionConfiguration,
                sessionDelegate: sessionDelegate,
                communicator: communicator
            )
        }()
        
        public static let retail: Dependencies = {
            let blockchainAPIConfig = Config.retailConfig
            let sessionConfiguration = URLSessionConfiguration.default
            if let userAgent = UserAgentProvider.shared.userAgent {
                sessionConfiguration.httpAdditionalHeaders = [HttpHeaderField.userAgent: userAgent]
            }
            sessionConfiguration.waitsForConnectivity = true
            let sessionDelegate = SessionDelegate()
            let session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
            let communicator = NetworkCommunicator(session: session, sessionDelegate: sessionDelegate)
            let requestBuilder = RequestBuilder(networkConfig: blockchainAPIConfig)
            return Dependencies(
                blockchainAPIConfig: blockchainAPIConfig,
                session: session,
                requestBuilder: requestBuilder,
                sessionConfiguration: sessionConfiguration,
                sessionDelegate: sessionDelegate,
                communicator: communicator
            )
        }()
        
        public static let everypay: Dependencies = {
            
            class SessionHandler: NetworkSessionDelegateAPI {
                func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler) {
                    completionHandler(.performDefaultHandling, nil)
                }
            }
            
            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.waitsForConnectivity = true
            let sessionDelegate = SessionDelegate()
            let session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
            let communicator = NetworkCommunicator(
                session: session,
                sessionDelegate: sessionDelegate,
                sessionHandler: SessionHandler()
            )
            let config = Config.everypayConfig
            let requestBuilder = RequestBuilder(networkConfig: config)
            return Dependencies(
                blockchainAPIConfig: config,
                session: session,
                requestBuilder: requestBuilder,
                sessionConfiguration: sessionConfiguration,
                sessionDelegate: sessionDelegate,
                communicator: communicator
            )
        }()
    }
}

public protocol DeviceInfo {
    var systemVersion: String { get }
    var model: String { get }
}

public class UserAgentProvider {
    
    public static let shared = UserAgentProvider()
    
    private var deviceInfo: DeviceInfo?
    
    var userAgent: String? {
        guard
            let systemVersion = deviceInfo?.systemVersion,
            let modelName = deviceInfo?.model,
            let version = Bundle.applicationVersion,
            let build = Bundle.applicationBuildVersion
        else {
            return nil
        }
        let versionAndBuild = String(format: "%@ b%@", version, build)
        return String(format: "Blockchain-iOS/%@ (iOS/%@; %@)", versionAndBuild, systemVersion, modelName)
    }
    
    public func apply(deviceInfo: DeviceInfo) {
        self.deviceInfo = deviceInfo
    }
}

protocol NetworkSessionDelegateAPI: class {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler)
}

protocol SessionDelegateAPI: class, URLSessionDelegate {
    var delegate: NetworkSessionDelegateAPI? { get set }
}

private class SessionDelegate: NSObject, SessionDelegateAPI {
    public weak var delegate: NetworkSessionDelegateAPI?
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {}
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping AuthChallengeHandler) {
        delegate?.urlSession(session, didReceive: challenge, completionHandler: completionHandler)
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
}

public typealias AuthChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void

public typealias URLParameters = [String: Any]

public typealias URLHeaders = [String: String]

extension HTTPMethod {
    var networkRequestMethod: NetworkRequest.NetworkMethod {
        switch self {
        case .get:
            return NetworkRequest.NetworkMethod.get
        case .post:
            return NetworkRequest.NetworkMethod.post
        case .put:
            return NetworkRequest.NetworkMethod.put
        case .patch:
            return NetworkRequest.NetworkMethod.patch
        case .delete:
            return NetworkRequest.NetworkMethod.delete
        }
    }
}

extension Bool {
    var encoded: String {
        self ? "true" : "false"
    }
}
