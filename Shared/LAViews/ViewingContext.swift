//
//  ViewingContext.swift
//  Loom
//
//  Created by PEXAVC on 8/12/23.
//

import Foundation
import LemmyKit

enum ViewingContext: Equatable {
    case base
    case source
    case peer
    case bookmark(String)
    case bookmarkExpanded(String)
    case search
    case profile
    case screenshot
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
    
    var bookmarkLocation: FetchType {
        switch self {
        case .bookmark(let host), .bookmarkExpanded(let host):
            return .peer(host)
        default:
            return .source
        }
    }
}
