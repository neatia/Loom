//
//  ListingType.swift
//  Loom
//
//  Created by PEXAVC on 8/11/23.
//

import Foundation
import LemmyKit
import SwiftUI

extension ListingType {
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
}
