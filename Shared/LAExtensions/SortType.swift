//
//  SortType.swift
//  Loom
//
//  Created by PEXAVC on 8/11/23.
//

import Foundation
import SwiftUI
import FederationKit

extension FederatedSortType {
    static var categoryGeneral: [FederatedSortType] {
        [.hot, .active, .topAll, .new,]
    }
    
    static var categoryTime: [FederatedSortType] {
        [.topAll, .topYear, .topDay]
    }
    
    var isTime: Bool {
        switch self {
        case .topAll, .topMonth, .topDay, .topYear, .topHour, .topWeek:
            return true
        default:
            return false
        }
    }
    
    var displayString: LocalizedStringKey {
        switch self {
        case .topAll:
            return "SORT_TYPE_TOP"
        case .topYear:
            return "SORT_TYPE_YEAR"
        case .topDay:
            return "SORT_TYPE_TODAY"
        case .hot:
            return "SORT_TYPE_HOT"
        case .active:
            return "SORT_TYPE_ACTIVE"
        case .new:
            return "SORT_TYPE_NEW"
        case .old:
            return "SORT_TYPE_OLD"
        default:
            return .init(self.rawValue)
        }
    }
}

