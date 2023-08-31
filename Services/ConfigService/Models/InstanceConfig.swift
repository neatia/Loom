//
//  InstanceConfig.swift
//  Loom
//
//  Created by PEXAVC on 7/13/23.
//

import Granite
import Foundation
import IPFSKit
import FederationKit

extension FederationServer {
    static var `default`: FederationServer {
        .init(.lemmy, host: "https://lemmy.world")
    }
}

struct InfuraGateway: IPFSGateway {
    var host: any IPFSHost {
        InfuraHost(id: key,
                   secret: secret)
    }
    
    let key: String
    let secret: String
    let gateway: String
    init(_ key: String, secret: String, gateway: String) {
        self.key = key
        self.secret = secret
        self.gateway = gateway
    }
}

//Example IPFS Setup
/*
public struct InfuraHost: IPFSHost {
    public var url: String {
        "ipfs.infura.io"
    }
    
    public var port: Int
    
    public var ssl: Bool { true }
    
    public var version: String {
        "/api/v0/"
    }
    
    public var id: String?
    public var secret: String?
    
    public init(port: Int = 5001,
                id: String,
                secret: String) {
        self.port = port
        self.id = id
        self.secret = secret
    }
}

 struct InfuraGateway: IPFSGateway {
     var host: any IPFSHost {
         InfuraHost(id: "",//On Infura, this is simply the API_KEY
                    secret: "")//API_KEY_SECRET
     }
     
     var gateway: String {
         ""
     }
 }

*/
