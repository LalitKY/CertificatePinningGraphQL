

import Foundation
import Apollo
import ApolloWebSocket
import Security
import CommonCrypto
import UIKit

/// Custom class to do ssl pinning using fingerprints
final class PromiscuousURLSessionClient: URLSessionClient {
    
    override func urlSession( _ session: URLSession,
                              didReceive challenge: URLAuthenticationChallenge,
                              completionHandler: @escaping ( URLSession.AuthChallengeDisposition,
                                                             URLCredential? ) -> Void ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge,nil)
            return
        }
        if validate(serverTrust: serverTrust){
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    /// Validates an object used to evaluate trust's certificate by comparing their's fingerprint to the known
    /// trused fingerprint stored in the app
    /// - Parameter serverTrust: The object used to evaluate trust.
    /// - Returns: Validate and compare local fingerprint with server certificate fingerprint 
    func validate(serverTrust: SecTrust) -> Bool {
        let fingerPrints = ["67add1166b020ae61b8f5fc96813c04c2aa589960796865572a3c7e737613dfd",
         "96bcec06264976f37460779acf28c5a7cfe8a3c0aae11a8ffcee05c0bddf08c6"]
        // Check if the trust is valid
        let status = SecTrustEvaluateWithError(serverTrust, nil)
        guard status else {
            return false
        }
        // For each certificate in the valid trust:
        var fingerPrintMatchedCount = 0
        
        if #available(iOS 15, *) {
            if let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] {
                _ = certificates.map {
                    let remoteCertData: NSData = SecCertificateCopyData($0)
                    let fingerprint = (remoteCertData as Data).sha256()
                    if fingerPrints.contains(fingerprint) {
                        fingerPrintMatchedCount += 1
                    }
                }
            }
        } else {
            for index in 1..<SecTrustGetCertificateCount(serverTrust) {
                // Get the public key data for the certificate at the current index of the loop.
                guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, index) else {
                    return false
                }
                let remoteCertData: NSData = SecCertificateCopyData(certificate)
                let fingerprint = (remoteCertData as Data).sha256()
                if fingerPrints.contains(fingerprint) {
                    fingerPrintMatchedCount += 1
                }
            }
        }
        
        return fingerPrintMatchedCount >= 2
    }
}
