//
//  Actions.SetInstance.swift
//  Loom (iOS)
//
//  Created by Ritesh Pakala on 9/4/23.
//

import Foundation

struct Actions {
    static let userDefault = UserDefaults(suiteName: "group.nyc.loom")
    
    struct SetInstance {
        
        static func retrieveURL() -> URL? {
            guard let value = Actions.userDefault?.string(forKey: "instanceURL") else {
                print("none found \(Actions.userDefault == nil)")
                return nil
            }
            
            defer {
                Actions.userDefault?.removeObject(forKey: "instanceURL")
            }
            
            return URL(string: value)
        }
    }
}
