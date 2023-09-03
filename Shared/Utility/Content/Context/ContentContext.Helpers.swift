//
//  ContentContext.Helpers.swift
//  Loom
//
//  Created by PEXAVC on 8/26/23.
//

import Foundation
import FederationKit

extension ContentContext {
    var viewbaleHosts: [String] {
        var hosts = commentModel?.viewableHosts ?? []
        hosts += postModel?.viewableHosts ?? []
        
        if viewingContext.isBookmark,
           case .peer(let host) = viewingContext.bookmarkLocation {
            hosts += [host]
        }
        
        return hosts
    }
    
    var canInteract: Bool {
        return FederationKit.canInteract(location.host ?? FederationKit.host)
    }
}
