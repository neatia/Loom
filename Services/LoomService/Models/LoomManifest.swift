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
    var data: [FederatedData] { get set }
}

struct LoomManifest: AnyLoomManifest, Identifiable, Hashable {
    var id: UUID = .init()
    
    var meta: LoomManifestMeta
    var data: [FederatedData] = []
    
    init(meta: LoomManifestMeta) {
        self.meta = meta
    }
    
    mutating func insert(_ fc: FederatedCommunity) {
        self.data.insert(.community(fc), at: 0)
    }
    
    mutating func remove(_ fc: FederatedCommunity) {
        let id = LemmyKit.host + (fc.id)
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
    
    func contains(_ model: FederatedCommunity) -> Bool {
        let id = LemmyKit.host + (model.id)
        return self.data.first(where: { $0.idPlain == id }) != nil
    }
    
    func fetch(_ page: Int,
               limit: Int = 5,
               listing: ListingType,
               sorting: SortType,
               location: FetchType = .source) async -> [PostView] {
        
        var cumulativePosts: [PostView] = []
        for fc in data {
            let posts = await Lemmy.posts(fc.community?.lemmy?.community,
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
