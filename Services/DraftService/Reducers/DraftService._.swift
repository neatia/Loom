//
//  DraftService._.swift
//  Lemur
//
//  Created by Ritesh Pakala on 7/22/23.
//

import Foundation
import Granite
import SwiftUI
import LemmyKit

extension DraftService {
    struct OnAppear: GraniteReducer {
        typealias Center = DraftService.Center
        
        func reduce(state: inout Center.GenericGraniteState) {
            state.drafts[.uncategorized] = []
            var map: ManuscriptMap = [:]
            for i in 0..<12 {
                let mock = Manuscript.mock(i)
                map[mock.id] = mock
            }
            
            state.drafts[.uncategorized] = Array(map.keys)
            state.allManuscripts = map
        }
    }
    
    struct CreateCategory: GraniteReducer {
        typealias Center = DraftService.Center
        
        struct Meta: GranitePayload {
            var category: Category
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.GenericGraniteState) {
            guard let meta else { return }
            state.drafts[meta.category] = []
            state.categories = Array(state.drafts.keys).filter { $0 != .uncategorized }
        }
    }
    
    struct AddToCategory: GraniteReducer {
        typealias Center = DraftService.Center
        
        struct Meta: GranitePayload {
            var category: Category
            var manuscriptID: String
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.GenericGraniteState) {
            guard let meta else { return }
            
            var manuscripts = Set(state.drafts[meta.category] ?? [])
            
            manuscripts.insert(meta.manuscriptID)
            let category: Category = .init(title: meta.category.title, manuscriptIDs: Array(manuscripts))
            state.drafts[meta.category] = nil
            state.drafts[category] = Array(manuscripts)
            
            state.drafts[.uncategorized]?.removeAll(where: { $0 == meta.manuscriptID })
            state.categories = Array(state.drafts.keys).filter { $0 != .uncategorized }
            
            print("[DraftService] Adding: \(meta.manuscriptID) to \(meta.category.title)")
        }
    }
}
