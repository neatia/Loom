import Granite
import SwiftUI

extension DraftService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var drafts: [Category: [String]] = [:]
            var categories: [Category] = []
            var allManuscripts: ManuscriptMap = [:]
        }
        
        @Event var setMock: OnAppear.Reducer
        @Event var createCategory: CreateCategory.Reducer
        @Event var addToCategory: AddToCategory.Reducer
        
        @Store(persist: "persistence.drafts.0012", autoSave: true, preload: true) public var state: State
    }
    
    var uncategorized: [Manuscript] {
        (state.drafts[.uncategorized] ?? [])
            .compactMap {
                state.allManuscripts[$0]
            }
    }
    
}

typealias ManuscriptMap = [String : Manuscript]
