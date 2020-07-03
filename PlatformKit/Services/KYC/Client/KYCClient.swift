//
//  UserClient.swift
//  Blockchain
//
//  Created by Daniel Huri on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import RxSwift

public protocol KYCClientAPI: AnyObject {
    
    func tiers() -> Single<KYC.UserTiers>
    func supportedDocuments(for country: String) -> Single<KYCSupportedDocumentsResponse>
    func user() -> Single<NabuUser>
    func listOfStates(in country: String) -> Single<[KYCState]>
    
    func selectCountry(country: String, state: String?, notifyWhenAvailable: Bool, jwtToken: String) -> Completable
    func updatePersonalDetails(firstName: String?, lastName: String?, birthday: Date?) -> Completable
    func updateAddress(userAddress: UserAddress) -> Completable

    func credentialsForVeriff() -> Single<VeriffCredentials>
    func submitToVeriffForVerification(applicantId: String) -> Completable
}

public final class KYCClient: KYCClientAPI {
    
    // MARK: - Types
    
    private enum Path {
        
        // GET
        
        static let tiers = ["kyc", "tiers"]
        static let credentials = [ "kyc", "credentials" ]
        static let credentiasForVeriff = [ "kyc", "credentials", "veriff" ]
        static let currentUser = [ "users", "current" ]
        static func supportedDocuments(for country: String) -> [String] {
            [ "kyc", "supported-documents", country ]
        }
        static func listOfStates(in country: String) -> [String] {
            ["countries", country, "states"]
        }
        
        // POST
        
        static let country = [ "users", "current", "country" ]
        static let verifications = [ "verifications" ]
        static let submitVerification = [ "kyc", "verifications" ]

        // PUT
        
        static let updateAddress = [ "users", "current", "address" ]
        static let updateUserDetails = [ "users", "current" ]
    }
    
    // MARK: - Properties
    
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Setup
    
    public init(dependencies: Network.Dependencies = .retail) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }
    
    public func tiers() -> Single<KYC.UserTiers> {
        let request = requestBuilder.get(
            path: Path.tiers,
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    public func supportedDocuments(for country: String) -> Single<KYCSupportedDocumentsResponse> {
        let request = requestBuilder.get(
            path: Path.supportedDocuments(for: country),
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    public func credentialsForVeriff() -> Single<VeriffCredentials> {
        let request = requestBuilder.get(
            path: Path.credentiasForVeriff,
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    public func user() -> Single<NabuUser> {
        let request = requestBuilder.get(
            path: Path.currentUser,
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    public func listOfStates(in country: String) -> Single<[KYCState]> {
        let request = requestBuilder.get(
            path: Path.listOfStates(in: country)
        )!
        return communicator
            .perform(request: request)
            .map { (states: [KYCState]) in
                states.sorted { $0.name.uppercased() < $1.name.uppercased() }
            }
    }
    
    public func submitToVeriffForVerification(applicantId: String) -> Completable {
        struct Payload: Encodable {
            
            private enum CodingKeys: String, CodingKey {
                case applicantId
                case clientType = "X-CLIENT-TYPE"
            }
            
            let applicantId: String
            let clientType: String
            
            init(applicantId: String) {
                self.applicantId = applicantId
                self.clientType = HttpHeaderValue.clientTypeApp
            }
        }

        let payload = Payload(applicantId: applicantId)
        
        let request = requestBuilder.post(
            path: Path.submitVerification,
            body: try? payload.encode(),
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    public func selectCountry(country: String,
                              state: String?,
                              notifyWhenAvailable: Bool,
                              jwtToken: String) -> Completable {
        struct Payload: Encodable {
            let jwt: String
            let countryCode: String
            let state: String?
            let notifyWhenAvailable: String
            
            init(jwt: String, country: String, state: String?, notifyWhenAvailable: Bool) {
                self.jwt = jwt
                self.countryCode = country
                self.state = state
                self.notifyWhenAvailable = "\(notifyWhenAvailable)"
            }
        }
        
        let payload = Payload(
            jwt: jwtToken,
            country: country,
            state: state,
            notifyWhenAvailable: notifyWhenAvailable
        )
        
        let request = requestBuilder.post(
            path: Path.country,
            body: try? payload.encode(),
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    public func updatePersonalDetails(firstName: String?, lastName: String?, birthday: Date?) -> Completable {
        let payload = KYCUpdatePersonalDetailsRequest(
            firstName: firstName,
            lastName: lastName,
            birthday: birthday
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.birthday)
        
        let request = requestBuilder.put(
            path: Path.updateUserDetails,
            body: try? encoder.encode(payload),
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    public func updateAddress(userAddress: UserAddress) -> Completable {
        let payload = KYCUpdateAddressRequest(address: userAddress)
        let request = requestBuilder.put(
            path: Path.updateAddress,
            body: try? payload.encode(),
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
}

