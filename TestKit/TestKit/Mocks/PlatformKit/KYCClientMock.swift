//
//  KYCClientMock.swift
//  PlatformKitTests
//
//  Created by Daniel on 26/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

final class KYCClientMock: KYCClientAPI {
    
    var expectedTiers: Result<KYC.UserTiers, Error>!
    func tiers() -> Single<KYC.UserTiers> {
        expectedTiers.single
    }
    
    var expectedSupportedDocuments: Result<KYCSupportedDocumentsResponse, Error>!
    func supportedDocuments(for country: String) -> Single<KYCSupportedDocumentsResponse> {
        expectedSupportedDocuments.single
    }
    
    var expectedUser: Result<NabuUser, Error>!
    func user() -> Single<NabuUser> {
        expectedUser.single
    }
    
    var expectedListOfStates: Result<[KYCState], Error>!
    func listOfStates(in country: String) -> Single<[KYCState]> {
        expectedListOfStates.single
    }

    var expectedSelectCountry: Completable!
    func selectCountry(country: String, state: String?, notifyWhenAvailable: Bool, jwtToken: String) -> Completable {
        expectedSelectCountry
    }
    
    var expectedPersonalDetails: Completable!
    func updatePersonalDetails(firstName: String?, lastName: String?, birthday: Date?) -> Completable {
        expectedPersonalDetails
    }
    
    var expectedUpdateAddressCompletable: Completable!
    func updateAddress(userAddress: UserAddress) -> Completable {
        expectedUpdateAddressCompletable
    }

    var expectedCredentials: Result<VeriffCredentials, Error>!
    func credentialsForVeriff() -> Single<VeriffCredentials> {
        expectedCredentials.single
    }
    
    var expectedSubmitToVeriffForVerification: Completable!
    func submitToVeriffForVerification(applicantId: String) -> Completable {
        expectedSubmitToVeriffForVerification
    }
        
    var jwtToken: Result<String, Error>!
    func requestJWT(guid: String, sharedKey: String) -> Single<String> {
        jwtToken.single
    }
}
