import Granite
import SwiftUI

extension Loom: View {
    public var view: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                LoomSymbolView(displayKind: _state.display,
                               isCreating: _state.isCreating,
                               intent: service._state.intent)
                
                if state.display == .expanded {
                    LoomCollectionsView(isCreaing: _state.isCreating,
                                        intent: service._state.intent,
                                        activeManifest: service._state.activeManifest,
                                        manifests: service.manifests)
                    .attach({ intent in
                        service.center.modify.send(intent)
                    }, at: \.add)
                    .attach({ manifest in
                        service.center.modify.send(LoomService.Modify.Intent.toggle(manifest))
                    }, at: \.toggle)
                }
            }
            
            if state.isCreating {
                LoomCreateView(isCreating: _state.isCreating)
                    .attach({ name in
                        service.center.modify.send(LoomService.Modify.Intent.create(name, nil))
                    }, at: \.create)
            }
        }
        .onChange(of: service.state.intent) { newIntent in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                switch newIntent {
                case .adding:
                    _state.display.wrappedValue = .expanded
                case .idle:
                    _state.display.wrappedValue = .compact
                }
            }
        }
    }
}
