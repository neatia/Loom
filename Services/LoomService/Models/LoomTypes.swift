//
//  LoomTypes.swift
//  Loom
//
//  Created by PEXAVC on 8/17/23.
//

import Foundation
import LemmyKit
import Granite

/* FederationKit */

struct FederatedData: Identifiable, Hashable, Equatable, Codable {
    static func == (lhs: FederatedData, rhs: FederatedData) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: UUID = .init()
    var host: String
    var community: FederatedCommunity?
    var instance: FederatedInstance?
    
    init(host: String,
         community: FederatedCommunity? = nil,
         instance: FederatedInstance? = nil) {
        self.host = host
        self.community = community
        self.instance = instance
    }
    
    
    var idPlain: String {
        "\(host)\(community?.id ?? "")\(instance?.id ?? "")"
    }
    
    var displayName: String {
        community?.displayName ?? ""
    }
    
    static func community(_ fc: FederatedCommunity?) -> FederatedData {
        print("{TEST} \(LemmyKit.host)")
        return .init(host: LemmyKit.host, community: fc)
    }
    
    enum CodingKeys: CodingKey {
        case id,
             host,
             lemmyCommunity,
             lemmyInstance
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let lc = community as? CommunityView {
            try container.encode(lc, forKey: .lemmyCommunity)
        }
        
        if let li = instance as? Instance {
            try container.encode(li, forKey: .lemmyInstance)
        }
        
        try container.encode(host, forKey: .host)
        try container.encode(id, forKey: .id)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.host = try container.decode(String.self, forKey: .host)
        
        if let lc = try? container.decode(CommunityView.self, forKey: .lemmyCommunity) {
            self.community = lc
        }
        
        if let li = try? container.decode(Instance.self, forKey: .lemmyInstance) {
            self.instance = li
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

protocol FederatedCommunity: Codable, Decodable {
    var instanceType: FederatedInstanceType { get }
    
    var id: String { get }
    var displayName: String { get }
    var actor_id: String { get }
    
    var lemmy: CommunityView? { get }
}

protocol FederatedInstance: Codable, Decodable {
    var instanceType: FederatedInstanceType { get }
    
    var domain: String { get }
}

extension FederatedInstance {
    var id: String { domain }
}

enum FederatedInstanceType: String {
    case lemmy
}

/* Lemmy extensions */

extension CommunityView: FederatedCommunity {
    var lemmy: CommunityView? {
        self
    }
    
    var instanceType: FederatedInstanceType {
        .lemmy
    }
    
    var actor_id: String {
        self.community.actor_id
    }
}

extension Instance: FederatedInstance {
    var instanceType: FederatedInstanceType {
        .lemmy
    }
}

