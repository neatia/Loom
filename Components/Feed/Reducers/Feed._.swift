//
//  Feed.Fetch.swift
//  Loom
//
//  Created by PEXAVC on 7/13/23.
//

import Granite

extension Feed {
    struct GoHome: GraniteReducer {
        typealias Center = Feed.Center
        
        @Relay var layout: LayoutService
        
        func reduce(state: inout Center.State) async {
            layout.preload()
            layout._state.feedCommunityContext.wrappedValue = .idle
            state.community = nil
            state.communityView = nil
            state.location = .base
            state.peerLocation = nil
        }
        
        var behavior: GraniteReducerBehavior {
            .task(.userInitiated)
        }
    }
}
