import Granite
import SwiftUI

extension Loom: View {
    public var view: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                LoomSymbolView(displayKind: service._state.display,
                               intent: service._state.intent)
                
                if service.state.display == .expanded {
                    LoomCollectionsView(intent: service._state.intent,
                                        activeManifest: service._state.activeManifest,
                                        manifests: service.manifests)
                    .attach({ intent in
                        service.center.modify.send(intent)
                    }, at: \.add)
                    .attach({ manifest in
                        service.center.modify.send(LoomService.Modify.Intent.toggle(manifest))
                    }, at: \.toggle)
                    .attach({ manifest in
                        service._state.intent.wrappedValue = .edit(manifest)
                    }, at: \.edit)
                }
            }
            
            switch service.state.intent {
            case .edit(let model):
                LoomEditView(intent: service._state.intent,
                             manifest: model)
            case .creating:
                LoomCreateView(intent: service._state.intent)
                    .attach({ name in
                        service.center.modify.send(LoomService.Modify.Intent.create(name, nil))
                    }, at: \.create)
                    .shadow(color: Brand.Colors.black, radius: 6)
            default:
                EmptyView()
            }
            
        }
//        .task {
//            service._state.display.wrappedValue = .compact
//        }
        .onChange(of: service.state.intent) { newIntent in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                switch newIntent {
                case .adding:
                    service._state.display.wrappedValue = .expanded
                default:
                    break
                }
            }
        }
    }
}
