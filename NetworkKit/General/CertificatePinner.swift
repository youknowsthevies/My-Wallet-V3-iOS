//
//  CertificatePinner.swift
//  Blockchain
//
//  Created by Maurice A. on 4/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit

/**
 Handles certificate pinning for connections to blockchain.info.
 # Usage
 TBD
 - Author: Maurice Achtenhagen
 - Copyright: Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
 */
@objc
final public class CertificatePinner: NSObject {

    // MARK: - Properties

    /// The instance variable used to access functions of the `CertificatePinner` class.
    @objc public static let shared = CertificatePinner()

    /// Path to the local certificate file
    @objc public var localCertificatePath: String? {
        guard
            let path = Bundle.main.path(forResource: "blockchain", ofType: "der", inDirectory: "Cert") else {
                return nil
        }
        return path
    }
    
    private let session: URLSession

    // MARK: - Initialization

    //: Prevent outside objects from creating their own instances of this class.
    override public init() {
        self.session = Network.Dependencies.default.session
        super.init()
    }

    init(session: URLSession) {
        self.session = session
        super.init()
    }

    public func pinCertificateIfNeeded() {
        guard BlockchainAPI.shared.shouldPinCertificate else {
            return
        }
        let walletUrl = BlockchainAPI.shared.walletUrl
        guard let url = URL(string: walletUrl) else {
            fatalError("Failed to get wallet url from Bundle.")
        }
        session.sessionDescription = url.host
        // TODO:
        // * inject NetworkCommunicator
        let task = session.dataTask(with: url) { _, _, _ in }
        task.resume()
    }

    @objc
    public func didReceive(_ challenge: URLAuthenticationChallenge, completion: @escaping AuthChallengeHandler) {
        respond(to: challenge, completion: completion)
    }

    private func respond(to challenge: URLAuthenticationChallenge, completion: AuthChallengeHandler) {
        var localTrust: SecTrust?
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completion(.cancelAuthenticationChallenge, nil)
            return
        }

        guard
            let certificatePath = localCertificatePath,
            let certificateData = NSData(contentsOfFile: certificatePath),
            let localCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, certificateData) else {
                completion(.cancelAuthenticationChallenge, nil)
                return
        }

        let policy = SecPolicyCreateBasicX509()

        // Public key pinning check
        if SecTrustCreateWithCertificates(localCertificate, policy, &localTrust) == errSecSuccess {
            let localPublicKey = SecTrustCopyPublicKey(localTrust!)
            let serverPublicKey = SecTrustCopyPublicKey(serverTrust)
            if (localPublicKey as AnyObject).isEqual(serverPublicKey as AnyObject) {
                let credential = URLCredential(trust: serverTrust)
                completion(.useCredential, credential)
            } else {
                Logger.shared.error("Failed Certificate Validation")
                completion(.cancelAuthenticationChallenge, nil)
            }
        }
    }
}
