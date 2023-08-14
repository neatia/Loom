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

struct LoomManifest: GraniteModel, Identifiable, Hashable {
    var id: UUID = .init()
    
    var meta: Meta
    var communities: [CommunityView] = []
    
    var collectionNamesList: [String] {
        communities.map { $0.displayName }
    }
    
    var collectionNames: String {
        collectionNamesList.joined(separator: ", ")
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func contains(_ model: CommunityView) -> Bool {
        self.communities.first(where: { $0.id == model.id }) != nil
    }
    
    func fetch(_ page: Int,
               limit: Int = 5,
               listing: ListingType,
               sorting: SortType,
               location: FetchType = .source) async -> [PostView] {
        
        var cumulativePosts: [PostView] = []
        for communityView in communities {
            let posts = await Lemmy.posts(communityView.community,
                                          type: listing,
                                          page: page,
                                          limit: limit,
                                          sort: sorting,
                                          location: location)
            cumulativePosts.append(contentsOf: posts)
        }
        return cumulativePosts
    }
}

extension LoomManifest {
    struct Meta: GraniteModel, Hashable {
        var title: String
        var name: String
        var createdDate: Date = .init()
        var updatedDate: Date = .init()
    }
}
