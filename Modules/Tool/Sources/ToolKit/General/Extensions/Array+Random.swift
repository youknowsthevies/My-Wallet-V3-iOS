// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Array where Element == UInt8 {
    /// Returns an Array of random UInt8 elements by using `SecRandomCopyBytes`
    /// - Parameter count: The count of the random bytes
    /// - Returns: An array of UInt8 elements
    public static func secureRandomBytes(count: Int) -> Array {
        Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            let result = SecRandomCopyBytes(kSecRandomDefault, count, buffer.baseAddress!)
            initializedCount = (result == errSecSuccess) ? count : 0
        }
    }
}
