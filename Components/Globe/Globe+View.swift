import Granite
import GraniteUI
import SwiftUI
import LemmyKit

extension Globe: View {
    public var view: some View {
        VStack(spacing: 0) {
            
            #if os(iOS)
            VStack(spacing: 0) {
                mainView
                
                Picker("", selection: _state.socialViewOptions) {
                    Text("TITLE_COMMUNITIES").tag(0)
                    Text("TITLE_BLOCKED").tag(1)
                        .autocapitalization(.words)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, .layer3)
                .padding(.bottom, .layer4)
                
                if state.socialViewOptions == 0 {
                    socialViews
                        .id(isTabSelected)
                } else {
                    blockedView
                        .id(isTabSelected)
                }
            }
            #elseif os(macOS)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    mainView
                    
                    Divider()
                    
                    blockedView
                        .id(isTabSelected)
                        .padding(.top, .layer5)
                }
            }
            
            #endif
            
        }
        .addGraniteSheet(modal.sheetManager,
                         modalManager: modal.modalSheetManager,
                         background: Color.clear)
        .addGraniteModal(modal.modalManager)
        
    }
    
    var addView: some View {
        Button {
            GraniteHaptic.light.invoke()
            
            modal.presentSheet {
                LoginView(addToProfiles: true)
                    .attach({
                        modal.dismissSheet()
                    }, at: \.cancel)
                    .attach({
                        modal.dismissSheet()
                    }, at: \.add)
            }
        } label: {
            AppBlurView(size: .init(width: 0, height: state.accountModuleSize)) {
                Image(systemName: "plus")
                    .font(Fonts.live(.largeTitle, .bold))
                    .frame(width: state.accountModuleSize, height: state.accountModuleSize)
            }
            .frame(width: state.accountModuleSize, height: state.accountModuleSize)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: state.accountModuleSize, height: state.accountModuleSize)
    }
    
    var accountsView: some View {
        ScrollView([.vertical]) {
            HStack {
                LazyHGrid(rows: [GridItem(.flexible())],
                          alignment: .top,
                          spacing: .layer4) {
                    
                    addView
                    
                    ForEach(Array(account.state.profiles)) { meta in
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            
                            modal.presentModal(GraniteAlertView(message: .init("ALERT_SWITCH_ACCOUNT \("@\(meta.username)@\(meta.hostDisplay)")")) {
                                
                                GraniteAlertAction(title: "MISC_NO")
                                GraniteAlertAction(title: "MISC_YES") {
                                    config.center.restart.send(ConfigService.Restart.Meta(accountMeta: meta))
                                }
                            })
                            
                        } label: {
                            AccountModuleView(model: meta,
                                              size: .init(width: state.accountModuleSize, height: state.accountModuleSize),
                                              isActive: account.state.meta?.id == meta.id)
                            .id(account.state.meta)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: state.accountModuleSize, height: state.accountModuleSize)
                    }
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
                .padding(.layer4)
                
                Spacer()
            }
        }
    }
    
    var socialViews: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: .layer4) {
                    VStack {
                        Spacer()
                        Text("TITLE_COMMUNITIES")
                            .font(.title2.bold())
                    }
                    
                    Spacer()
                }
                .frame(height: 36)
                .padding(.leading, .layer4)
                .padding(.trailing, .layer4)
                
                CommunityPickerView(modal: false, verticalPadding: 0)
                    .id(config.center.state.config)
            }
        }
    }
    
    var blockedView: some View {
        VStack(spacing: 0) {
            HStack(spacing: .layer4) {
                VStack {
                    Spacer()
                    
                    Text("TITLE_BLOCKED")
                        .font(Device.isMacOS ? .title.bold() : .title2.bold())
                }
                
                Spacer()
            }
            .frame(height: 36)
            .padding(.leading, .layer4)
            .padding(.trailing, .layer4)
            
            BlockedPickerView(meta: account.state.meta,
                              modal: false,
                              verticalPadding: 0)
            .graniteEvent(account.center.interact)
        }
    }
}
