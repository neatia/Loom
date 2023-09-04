import Granite
import GraniteUI
import SwiftUI

extension Loom: View {
    public var view: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: .layer4) {
                    Button {
                        guard Device.isExpandedLayout == false,
                              state.viewOption != .looms else { return }
                        GraniteHaptic.light.invoke()
                        _state.viewOption.wrappedValue = .looms
                    } label: {
                        VStack {
                            Spacer()
                            //TODO: localize
                            Text("Looms")
                                .font(state.viewOption == .looms ? .title.bold() : .title2.bold())
                                .opacity(state.viewOption == .looms ? 1.0 : 0.6)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if Device.isExpandedLayout == false {
                        Button {
                            guard state.viewOption != .communities else { return }
                            GraniteHaptic.light.invoke()
                            _state.viewOption.wrappedValue = .communities
                        } label: {
                            VStack {
                                Spacer()
                                Text("TITLE_COMMUNITIES")
                                    .font(state.viewOption == .communities ? .title.bold() : .title2.bold())
                                    .opacity(state.viewOption == .communities ? 1.0 : 0.6)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                    
                    if state.viewOption == .looms {
                        Group {
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
                                    
                                    ModalService.shared.presentSheet {
                                        LoomCreateView(communityView: communityView)
                                            .attach({ name in
                                                service.center.modify.send(LoomService.Modify.Intent.create(name, nil))
                                                DispatchQueue.main.async {
                                                    ModalService.shared.dismissSheet()
                                                }
                                            }, at: \.create)
                                    }
                                    
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .font(.title3)
                                }.buttonStyle(.plain)
                            }
                        }.padding(.bottom, .layer1)
                    }
                }
                .frame(height: 36)
                .padding(.bottom, .layer4)
                .padding(.leading, .layer4)
                .padding(.trailing, .layer4)
                
                Divider()
                
                switch state.viewOption {
                case .looms:
                    LoomCollectionsView()
                        .attach({ manifest in
                            addToLoom(manifest)
                        }, at: \.add)
                        .attach({ model in
                            ModalService.shared.presentSheet {
                                LoomEditView(manifest: model)
                                    .attach({ manifest in
                                        service.center.modify.send(LoomService.Modify.Intent.removeManifest(manifest))
                                        ModalService.shared.dismissSheet()
                                    }, at: \.remove)
                                    .attach({ manifest in
                                        service.center.modify.send(LoomService.Modify.Intent.update(manifest))
                                        ModalService.shared.dismissSheet()
                                    }, at: \.edit)
                            }
                        }, at: \.edit)
                case .communities:
                    CommunityPickerView(modal: false, shouldRoute: true, verticalPadding: 0)
                }
            }
            
            if Device.isExpandedLayout {
                Divider()
                communitiesView
            }
        }
        .padding(.top, ContainerConfig.generalViewTopPadding)
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
        .background(Color.background)
    }
}

extension Loom {
    var communitiesView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: .layer4) {
                VStack {
                    Spacer()
                    Text("TITLE_COMMUNITIES")
                        .font(.title.bold())
                }
                
                Spacer()
            }
            .frame(height: 36)
            .padding(.bottom, .layer4)
            .padding(.leading, .layer4)
            .padding(.trailing, .layer4)
            
            Divider()
            
            CommunityPickerView(modal: false,
                                shouldRoute: true,
                                verticalPadding: 0)
        }
    }
}
