import Granite
import GraniteUI
import SwiftUI

extension Loom: View {
    public var view: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                VStack {
                    Spacer()
                    //TODO: localize
                    HStack(spacing: .layer4) {
                        Text("Looms")
                            .font(.title.bold())
                        
                        Spacer()
                        
                        if service.state.intent.isAdding {
                            Button {
                                GraniteHaptic.light.invoke()
                                service._state.intent.wrappedValue = .idle
                            } label: {
                                Text("MISC_DONE")
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .readability()
                                    .outline()
                            }.buttonStyle(.plain)
                        } else {
                            Button {
                                GraniteHaptic.light.invoke()
                                
                                modal.presentSheet {
                                    LoomCreateView(communityView: communityView)
                                        .attach({ name in
                                            service.center.modify.send(LoomService.Modify.Intent.create(name, nil))
                                            DispatchQueue.main.async {
                                                modal.dismissSheet()
                                            }
                                        }, at: \.create)
                                        .background(Color.background)
                                        .graniteNavigation(backgroundColor: Color.clear)
                                }
                                
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.title3)
                            }.buttonStyle(.plain)
                        }
                    }
                }
                .frame(height: 36)
                .padding(.bottom, .layer4)
                .padding(.leading, .layer4)
                .padding(.trailing, .layer4)
                
                Divider()
                
                LoomCollectionsView()
                .attach({ manifest in
                    modal.presentSheet {
                        CommunityPickerView()
                            .attach({ communityView in
                                GraniteHaptic.light.invoke()
                                
                                service.center.modify.send(LoomService.Modify.Intent.add(communityView, manifest))
                                
                            }, at: \.pickedCommunity)
                            .frame(width: Device.isMacOS ? 400 : nil, height: Device.isMacOS ? 400 : nil)
                    }
                }, at: \.add)
                .attach({ model in
                    modal.presentSheet {
                        LoomEditView(manifest: model)
                        .attach({ manifest in
                            service.center.modify.send(LoomService.Modify.Intent.removeManifest(manifest))
                            modal.dismissSheet()
                        }, at: \.remove)
                        .attach({ manifest in
                            service.center.modify.send(LoomService.Modify.Intent.update(manifest))
                            modal.dismissSheet()
                        }, at: \.edit)
                        .background(Color.background)
                        .graniteNavigation(backgroundColor: Color.clear)
                    }
                }, at: \.edit)
            }
            
        }
        .padding(.top, ContainerConfig.generalViewTopPadding)
        .addGraniteSheet(modal.sheetManager,
                         modalManager: modal.modalSheetManager,
                         background: Color.clear)
        .addGraniteModal(modal.modalManager)
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
