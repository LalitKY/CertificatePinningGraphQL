

import Foundation
import Security
import CommonCrypto

/// Data extension to return sha256 string
extension Data {
    
    /// returns sha256 string
    /// - Returns: Sha256 string
    func sha256() -> String {
        return hexStringFromData(input: digest(input: self as NSData))
    }
    
    /// Returns Data for certificate data digest
    /// - Parameter : input intake certificate data
    /// - Returns: Sha256 digested with NSdata
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    /// Returns hash string from data
    /// - Parameter : input intake certificate data
    /// - Returns: hash string
    private func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        return hexString
    }
}
