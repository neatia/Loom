import Granite
import FederationKit

extension LoomService {
    struct Modify: GraniteReducer {
        typealias Center = LoomService.Center
        
        enum Intent: GranitePayload, GraniteModel {
            case create(String, FederatedCommunityResource?)
            case add(FederatedCommunityResource, LoomManifest)
            case remove(FederatedCommunityResource, LoomManifest)
            case removeManifest(LoomManifest)
            case toggle(LoomManifest)
            case update(LoomManifest)
            case idle
        }
        
        @Payload var meta: Intent?
        
        func reduce(state: inout Center.State) {
            guard let meta else { return }
            switch meta {
            case .create(let name, let model):
                let user = FederationKit.user()
                var manifest: LoomManifest = .init(meta: .init(title: name, name: name, author: "\(user?.username ?? "")"))
                
                if let model {
                    manifest.insert(model)
                }
                
                state.manifests[manifest.id] = manifest
                
            case .add(let model, let manifest):
                var mutable = state.manifests[manifest.id] ?? manifest
                
                guard mutable.contains(model) == false else {
                    //TODO: localize
                    beam.send(StandardErrorMeta(title: "MISC_ERROR", message: "\(model.displayName) is already in this Loom", event: .error))
                    return
                }
                
                mutable.insert(model)
                mutable.meta.updatedDate = .init()
                
                state.manifests[manifest.id] = mutable
                
            case .remove(let model, let manifest):
                var mutable = manifest
                mutable.remove(model)
                mutable.meta.updatedDate = .init()
                
                state.manifests[manifest.id] = mutable
            case .removeManifest(let manifest):
                state.manifests[manifest.id] = nil
            case .toggle(let model):
                if state.activeManifest == model {
                    LoomLog("🪡 removing active loom", level: .debug)
                    state.activeManifest = nil
                    broadcast.send(LoomService.Control.deactivate)
                } else {
                    LoomLog("🪡 setting active loom", level: .debug)
                    state.activeManifest = model
                    broadcast.send(LoomService.Control.activate(model))
                }
            case .update(let model):
                var mutable = model
                mutable.meta.updatedDate = .init()
                state.manifests[mutable.id] = mutable
            default:
                break
            }
        }
    }
}

