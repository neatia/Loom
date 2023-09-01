//
//  ListingType.swift
//  Loom
//
//  Created by PEXAVC on 8/11/23.
//

import Foundation
import FederationKit
import SwiftUI

extension FederatedListingType {
    var abbreviated: String {
        switch self {
        case .subscribed:
            return "sub."
        default:
            return self.rawValue
        }
    }
    
    var displayString: LocalizedStringKey {
        switch self {
        case .all:
            return "LISTING_TYPE_ALL"
        case .local:
            return "LISTING_TYPE_LOCAL"
        case .subscribed:
            return "LISTING_TYPE_SUBSCRIBED"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .all:
            return "globe.americas"
        case .local:
            return "house"
        case .subscribed:
            return "book.closed"
        }
    }
}
