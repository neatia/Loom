import Granite
import SwiftUI

extension LoomService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var manifests: [UUID: LoomManifest] = [:]
            var activeManifest: LoomManifest? = nil
            var intent: Loom.Intent = .idle
            var display: Loom.DisplayKind = .compact
        }
        
        @Event var modify: Modify.Reducer
        
        @Store(persist: "persistence.Loom.service.0008",
               autoSave: true) public var state: State
        
    }
    
    enum Control: GranitePayload, GraniteModel {
        case activate(LoomManifest)
        case deactivate
        case idle
    }
    
    var manifests: [LoomManifest] {
        state.manifests.values.sorted(by: { $0.meta.updatedDate.compare($1.meta.updatedDate) == .orderedDescending })
    }
    
    func manifest(for idString: String) -> LoomManifest? {
        guard let uuid = UUID(uuidString: idString) else { return nil}
        return state.manifests[uuid]
    }
}
