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
    
    var bookmarkLocation: FetchType {
        switch self {
        case .bookmark(let host), .bookmarkExpanded(let host):
            return .peer(host)
        default:
            return .source
        }
    }
}
