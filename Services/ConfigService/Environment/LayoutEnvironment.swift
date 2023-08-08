//
//  LayoutEnvironment.swift
//  Loom
//
//  Created by PEXAVC on 7/29/23.
//

import Foundation
import SwiftUI
import LemmyKit
import Granite

class LayoutEnvironment: ObservableObject {
    enum Style: GraniteModel {
        case compact
        case expanded
    }
    
    enum FeedContext: GraniteModel {
        case viewPost(PostView)
        case idle
    }
    
    enum FeedCommunityContext: GraniteModel {
        case viewCommunityView(CommunityView)
        case viewCommunity(Community)
        case idle
    }
    
    
    @Published var closeDisplayView: Bool = true {
        didSet {
            #if os(macOS)
            if closeDisplayView {
                GraniteNavigationWindow.shared.updateWidth(720, id: "main")
            } else {
                GraniteNavigationWindow.shared.updateWidth(1200, id: "main")
            }
            #endif
        }
    }
    @Published var style: Style
    @Published var feedContext: FeedContext = .idle {
        didSet {
            switch feedContext {
            case .viewPost:
                self.closeDisplayView = false
            default:
                break
            }
        }
    }
    @Published var feedCommunityContext: FeedCommunityContext = .idle
    
    init() {
        #if os(macOS)
        style = .expanded
        #else
        style = .compact
        #endif
    }
}
