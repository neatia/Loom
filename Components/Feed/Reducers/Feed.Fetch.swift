//
//  Feed.Fetch.swift
//  Loom
//
//  Created by PEXAVC on 7/13/23.
//

import Granite
import LemmyKit

extension Feed {
    struct FetchInitial: GraniteReducer {
        typealias Center = Feed.Center
        
        struct Meta: GranitePayload {
            var force: Bool
        }
        
        @Payload var meta: Meta?
        
        @Relay var config: ConfigService
        @Relay var content: ContentService
        
        func reduce(state: inout Center.State) {
//            guard state.fetchedInitial == false || meta?.force == true else {
//                return
//            }
//            
//            //OnTask is running
//            
//            state.fetchedInitial = true
//            
//            state.isFetchingMore = true
            
//            content.center.fetchPosts.send(ContentService.FetchPosts.Meta(newPage: false, community: state.community, lastUpdate: content.state.lastUpdate))
        }
    }
}
