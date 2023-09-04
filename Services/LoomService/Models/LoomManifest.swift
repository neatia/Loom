//
//  LoomManifest.swift
//  Loom
//
//  Created by PEXAVC on 8/13/23.
//

import Foundation
import Granite
import SwiftUI
import FederationKit

protocol AnyLoomManifest: GraniteModel {
    var id: UUID { get }
    var meta: LoomManifestMeta { get }
    var data: [FederatedData] { get set }
}

struct LoomManifest: AnyLoomManifest, Identifiable, Hashable {
    var id: UUID = .init()
    
    var meta: LoomManifestMeta
    var data: [FederatedData] = []
    
    init(meta: LoomManifestMeta) {
        self.meta = meta
    }
    
    mutating func insert(_ fc: FederatedCommunityResource) {
        self.data.insert(.community(fc), at: 0)
    }
    
    mutating func remove(_ fc: FederatedCommunityResource) {
        let id = fc.community.actor_id.host + (fc.id)
        self.data.removeAll(where: { $0.idPlain == id })
    }
}

extension LoomManifest {
    var collectionNamesList: [String] {
        data.map { $0.displayName }
    }
    
    var collectionNames: String {
        collectionNamesList.joined(separator: ", ")
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func contains(_ model: FederatedCommunityResource) -> Bool {
        let id = FederationKit.host + (model.id)
        return self.data.first(where: { $0.idPlain == id }) != nil
    }
    
    func fetch(_ page: Int,
               limit: Int = 5,
               listing: FederatedListingType,
               sorting: FederatedSortType,
               location: FederatedLocationType = .source) async -> [FederatedPostResource] {
        
        var cumulativePosts: [FederatedPostResource] = []
        for fc in data {
            let posts = await Federation.posts(fc.community?.community,
                                               type: listing,
                                               page: page,
                                               limit: limit,
                                               sort: sorting,
                                               location: location,
                                               instanceType: fc.community?.community.instanceType)
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
