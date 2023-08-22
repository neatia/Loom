//
//  LoomManifest.swift
//  Loom
//
//  Created by PEXAVC on 8/13/23.
//

import Foundation
import Granite
import SwiftUI
import LemmyKit

protocol AnyLoomManifest: GraniteModel {
    var id: UUID { get }
    var meta: LoomManifestMeta { get }
    var communities: [FederatedCommunity] { get set }
    var instances: [FederatedInstance] { get set }
}

struct LoomManifest: AnyLoomManifest, Identifiable, Hashable {
    static func == (lhs: LoomManifest, rhs: LoomManifest) -> Bool {
        lhs.id == rhs.id &&
        lhs.communityIds == rhs.communityIds &&
        lhs.instanceIds == rhs.instanceIds &&
        lhs.meta == rhs.meta
    }
    
    var id: UUID = .init()
    
    var meta: LoomManifestMeta
    var communities: [FederatedCommunity] = []
    var instances: [FederatedInstance] = []
    
    /* these are used for equating */
    var communityIds: Set<String> = .init()
    var instanceIds: Set<String> = .init()
    
    enum CodingKeys: CodingKey {
        case id,
             meta,
             lemmyCommunities,
             lemmyInstances,
             communityIds,
             instanceIds
    }
    
    init(meta: LoomManifestMeta) {
        self.meta = meta
    }
    
    mutating func insert(_ fc: FederatedCommunity) {
        self.communities.insert(fc, at: 0)
        self.communityIds.insert(fc.id)
    }
    
    mutating func remove(_ fc: FederatedCommunity) {
        self.communities.removeAll(where: { $0.id == fc.id })
        self.communityIds.remove(fc.id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let lcs = communities as? [CommunityView] {
            try container.encode(lcs, forKey: .lemmyCommunities)
        }
        
        if let lci = instances as? [Instance] {
            try container.encode(lci, forKey: .lemmyInstances)
        }
        
        try container.encode(communityIds, forKey: .communityIds)
        try container.encode(instanceIds, forKey: .instanceIds)
        
        try container.encode(id, forKey: .id)
        try container.encode(meta, forKey: .meta)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.meta = try container.decode(LoomManifestMeta.self, forKey: .meta)
        
        self.communityIds = try container.decode(Set<String>.self, forKey: .communityIds)
        self.instanceIds = try container.decode(Set<String>.self, forKey: .instanceIds)
        
        if let lcs = try? container.decode([CommunityView].self, forKey: .lemmyCommunities) {
            self.communities = lcs
        }
        
        if let lci = try? container.decode([Instance].self, forKey: .lemmyInstances) {
            self.instances = lci
        }
    }
}

extension LoomManifest {
    var collectionNamesList: [String] {
        communities.map { $0.displayName }
    }
    
    var collectionNames: String {
        collectionNamesList.joined(separator: ", ")
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func contains(_ model: FederatedCommunity) -> Bool {
        self.communities.first(where: { $0.id == model.id }) != nil
    }
    
    func fetch(_ page: Int,
               limit: Int = 5,
               listing: ListingType,
               sorting: SortType,
               location: FetchType = .source) async -> [PostView] {
        
        var cumulativePosts: [PostView] = []
        for fcView in communities {
            let posts = await Lemmy.posts(fcView.lemmy?.community,
                                          type: listing,
                                          page: page,
                                          limit: limit,
                                          sort: sorting,
                                          location: location)
            cumulativePosts.append(contentsOf: posts)
        }
        cumulativePosts.shuffle()
        return cumulativePosts
    }
}

struct LoomManifestMeta: GraniteModel, Hashable {
    var title: String
    var name: String
    var author: String
    var createdDate: Date = .init()
    var updatedDate: Date = .init()
}
