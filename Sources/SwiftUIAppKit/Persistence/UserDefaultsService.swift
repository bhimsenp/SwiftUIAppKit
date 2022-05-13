import Foundation

public class UserDefaultsService {
    public static let shared = UserDefaultsService()

    public func save<T: Encodable>(_ obj: T, withKey key: String) {
        do {
            let data = try PropertyListEncoder().encode(obj)
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.synchronize()
        } catch {
            debugPrint(error)
        }
    }

    public func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }

    public func get<T: Decodable>(withKey key: String) -> T? {
        do {
            let data = UserDefaults.standard.data(forKey: key)
            guard let decoded = data else {
                return nil
            }
            return try PropertyListDecoder().decode(T.self, from: decoded)
        } catch {
            debugPrint(error)
            return nil
        }
    }

    public func saveString(_ value: String, withKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }

    public func getString(withKey key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }

    public func saveBool(_ value: Bool, withKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }

    public func getBool(withKey key: String) -> Bool? {
        UserDefaults.standard.bool(forKey: key)
    }
}
