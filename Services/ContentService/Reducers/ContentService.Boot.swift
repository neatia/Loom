//
//  ContentService.Boot.swift
//  Loom
//
//  Created by PEXAVC on 7/13/23.
//

import Foundation
import Granite

extension ContentService.Center {
    struct Boot: GraniteReducer {
        typealias Center = ContentService.Center
        
        func reduce(state: inout Center.State) {
            state.allPosts = [:]
            state.allComments = [:]
            state.allCommunities = [:]
            state.userContent = [:]
        }
    }
}
