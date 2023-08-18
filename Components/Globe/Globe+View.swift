import Granite
import GraniteUI
import SwiftUI
import LemmyKit

extension Globe: View {
    public var view: some View {
        VStack(spacing: 0) {
            
            if Device.isExpandedLayout == false {
                mainView
            } else {
                VStack(spacing: 0) {
                    switch state.tab {
                    case .explorer:
                        mainView
                    default:
                        HStack(spacing: 0) {
                            mainView
                            
                            Divider()
                            
                            blockedView
                                .id(isTabSelected)
                                .padding(.top, ContainerConfig.generalViewTopPadding)
                        }
                    }
                }
            }
            
        }
        .addGraniteSheet(modal.sheetManager,
                         modalManager: modal.modalSheetManager,
                         background: Color.clear)
        .addGraniteModal(modal.modalManager)
        .background(Color.background)
        
    }
    
    var addView: some View {
        Button {
            GraniteHaptic.light.invoke()
            
            modal.presentSheet(detents: [.large()]) {
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
    
    var socialViews: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                if Device.isExpandedLayout {
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
                }
                
                CommunityPickerView(modal: false, verticalPadding: 0)
                    .id(config.center.state.config)
            }
        }
    }
    
    var blockedView: some View {
        VStack(spacing: 0) {
            if Device.isExpandedLayout {
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
            }
            
            BlockedPickerView(meta: account.state.meta,
                              modal: false,
                              verticalPadding: 0)
            .graniteEvent(account.center.interact)
        }
    }
}
