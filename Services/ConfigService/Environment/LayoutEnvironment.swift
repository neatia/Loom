//
//  LayoutEnvironment.swift
//  Loom
//
//  Created by PEXAVC on 7/29/23.
//

import Foundation
import SwiftUI
import Granite
import FederationKit

class LayoutEnvironment: ObservableObject {
    enum Style: GraniteModel {
        case compact
        case expanded
    }
    
    enum FeedContext: GraniteModel {
        case viewPost(FederatedPostResource)
        case idle
    }
    
    enum FeedCommunityContext: GraniteModel {
        case viewCommunityView(FederatedCommunityResource)
        case viewCommunity(FederatedCommunity)
        case idle
    }
    
    
    @Published var closeDisplayView: Bool = true {
        didSet {
            #if os(macOS)
            if closeDisplayView {
                GraniteNavigationWindow.shared.updateWidth(720, id: GraniteNavigationWindow.defaultMainWindowId)
            } else {
                GraniteNavigationWindow.shared.updateWidth(1200, id: GraniteNavigationWindow.defaultMainWindowId)
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
