import Granite
import LemmyKit

extension LoomService {
    struct Modify: GraniteReducer {
        typealias Center = LoomService.Center
        
        enum Intent: GranitePayload, GraniteModel {
            case create(String, CommunityView?)
            case add(CommunityView, LoomManifest)
            case remove(CommunityView, LoomManifest)
            case toggle(LoomManifest)
            case update(LoomManifest)
            case idle
        }
        
        @Payload var meta: Intent?
        
        func reduce(state: inout Center.State) {
            guard let meta else { return }
            LoomLog("[LoomService] got intent")
            switch meta {
            case .create(let name, let model):
                var manifest: LoomManifest = .init(meta: .init(title: name, name: name))
                
                if let model {
                    manifest.communities.append(model)
                }
                
                state.manifests[manifest.id] = manifest
                
            case .add(let model, let manifest):
                var mutable = manifest
                mutable.communities.append(model)
                mutable.meta.updatedDate = .init()
                
                state.manifests[manifest.id] = mutable
                
            case .remove(let model, let manifest):
                var mutable = manifest
                mutable.communities.removeAll(where: { $0.id == model.id })
                mutable.meta.updatedDate = .init()
                
                state.manifests[manifest.id] = mutable
            
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

