import Granite
import SwiftUI
import LemmyKit

extension ExplorerService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var linkedInstances: [Instance] = []
            var allowedInstances: [Instance] = []
            var blockedInstances: [Instance] = []
            
            var lastUpdate: Date? = nil
        }
        
        @Event var boot: Boot.Reducer
        
        @Store(persist: "persistence.Loom.explorer.0011", autoSave: true) public var state: State
    }
}
