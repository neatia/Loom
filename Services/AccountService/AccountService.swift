import Granite
import Foundation

struct AccountService: GraniteService {
    @Service(.online) var center: Center
    
    static var keychainAuthToken: String = "nyc.stoic.Loom.app.auth.token"
    static var keychainService: String = "nyc.stoic.lemmy.Loom.app.keychain"
    
    static var keychainIPFSKeyToken: String = "nyc.stoic.lemmy.Loom.app.ipfs.key.token"
    static var keychainIPFSSecretToken: String = "nyc.stoic.lemmy.Loom.app.ipfs.secret.token"
    
    static func insertToken(_ token: Data,
                            identifier: String,
                            service: String) throws {
        
        let query: CFDictionary = [kSecClass as String : kSecClassGenericPassword,
                     kSecAttrService as String  : service,
                                   kSecAttrAccount as String  : identifier] as CFDictionary

        let attributes = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: identifier,
            kSecValueData: token
        ] as CFDictionary

        LoomLog("Inserting Token into | \(identifier) | Service: \(service) 🔑", level: .debug)
        let status = SecItemAdd(attributes, nil)
        guard status == errSecSuccess else {
            if status == errSecDuplicateItem {
                let status = SecItemUpdate(query, attributes)
            } else {
                throw KeychainError.unexpectedStatus(status)
            }
            return
        }
    }
    
    static func deleteToken(identifier: String,
                            service: String) throws {
        
        let query: CFDictionary = [kSecClass as String : kSecClassGenericPassword,
                     kSecAttrService as String  : service,
                                   kSecAttrAccount as String  : identifier] as CFDictionary

        LoomLog("Deleting Token | \(identifier) | Service: \(service) 🔑", level: .debug)
        
        let status = SecItemDelete(query)
    }
    
    static func getToken(identifier: String, service: String) throws -> String {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: identifier,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                // Technically could make the return optional and return nil here
                // depending on how you like this to be taken care of
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unexpectedStatus(status)
        }
        
        LoomLog("Retrieving Token | \(identifier) | Service: \(service) 🔑", level: .debug)
        // Lots of bang operators here, due to the nature of Keychain functionality.
        // You could work with more guards/if let or others.
        return String(data: result as! Data, encoding: .utf8)!
    }
}


//TODO:
/*
 - Keychain sharing
 - Read and unread posts/comments
 */
