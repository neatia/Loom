import Granite
import SwiftUI
import FederationKit

extension ExplorerService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var linkedInstances: [FederatedInstance] = []
            var allowedInstances: [FederatedInstance] = []
            var blockedInstances: [FederatedInstance] = []
            
            var favorites: [String: FederatedInstance] = [:]
            
            var lastUpdate: Date? = nil
        }
        
        @Event var boot: Boot.Reducer
        
        @Store(persist: "persistence.Loom.explorer.0017", autoSave: true) public var state: State
    }
}
