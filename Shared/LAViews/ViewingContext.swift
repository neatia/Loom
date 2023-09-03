//
//  ViewingContext.swift
//  Loom
//
//  Created by PEXAVC on 8/12/23.
//

import Foundation
import FederationKit

enum ViewingContext: Equatable {
    case base
    case source
    case peer
    case bookmark(String)
    case bookmarkExpanded(String)
    case search
    case profile
    case screenshot
    case postDisplay
    case thread(FederatedLocationType)
}

extension ViewingContext {
    var isBookmark: Bool {
        switch self {
        case .bookmark, .bookmarkExpanded:
            return true
        default:
            return false
        }
    }
    
    var isThread: Bool {
        switch self {
        case .thread:
            return true
        default:
            return false
        }
    }
    
    var isBookmarkExpanded: Bool {
        switch self {
        case .bookmarkExpanded:
            return true
        default:
            return false
        }
    }
    
    //TODO: think of a better name?
    var isBookmarkComponent: Bool {
        switch self {
        case .bookmark:
            return true
        default:
            return false
        }
    }
    
    var bookmarkLocation: FederatedLocationType {
        switch self {
        case .bookmark(let host), .bookmarkExpanded(let host):
            return .peer(host)
        default:
            return .source
        }
    }
    
    var threadLocation: FederatedLocationType {
        switch self {
        case .thread(let location):
            return location
        default:
            return .base
        }
    }
}
