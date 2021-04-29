// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public extension UserDefaults {
    func set<T: Encodable>(codable: T?, forKey key: String) {
        let encoder = JSONEncoder()
        guard let _ = codable else {
            self.set(nil, forKey: key)
            synchronize()
            return
        }
        do {
            let data = try encoder.encode(codable)
            let jsonString = String(data: data, encoding: .utf8)!
            self.set(jsonString, forKey: key)
            synchronize()
        } catch {
            Logger.shared.error("Saving \"\(key)\" failed: \(error)")
        }
    }

    func codable<T: Decodable>(_ codable: T.Type, forKey key: String) -> T? {
        guard let jsonString = self.string(forKey: key) else { return nil }
        guard let data = jsonString.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(codable, from: data)
    }
}
