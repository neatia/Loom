import Granite
import GraniteUI
import SwiftUI
import Foundation

extension Settings: View {
    var aboutPageLinkString: String {
        ""
    }
    
    public var view: some View {
        VStack(spacing: 0) {
            HStack(spacing: .layer4) {
                VStack {
                    Spacer()
                    Text("TITLE_SETTINGS")
                        .font(.title.bold())
                }
                
                Spacer()
            }
            .frame(height: 36)
            .padding(.bottom, .layer4)
            .padding(.leading, .layer4)
            .padding(.trailing, .layer4)
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                
//                VStack(alignment: .leading, spacing: 0) {
//                    Spacer()
//                    HStack {
//                        Text("TITLE_FEED")
//                            .font(.title2.bold())
//
//                        Spacer()
//                    }
//
//                    HStack {
//                        VStack(alignment: .leading, spacing: 0) {
//                            Toggle(isOn: config._state.linkPreviewMetaData) {
//                                Text("SETTINGS_FEED_LINK_DETAILS")
//                                    .font(.headline)
//                                    .offset(x: 0, y: Device.isMacOS ? -1 : 0)
//                            }
//                        }
//                        .padding(.vertical, .layer3)
//
//
//                        #if os(macOS)
//                        Spacer()
//                        #endif
//                    }
//                }
//                .padding(.top, .layer4)
//                .padding(.horizontal, .layer4)
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    HStack {
                        Group {
                            Text("MISC_IPFS")
                                .font(.title2.bold())+Text(" (Infura)")
                                .font(.title2.bold())
                        }
                            .addInfoIcon(text: "IPFS_INFO_TEMP", modal)
                        
                        Spacer()
                    }
                    .padding(.top, .layer4)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Toggle(isOn: config._state.enableIPFS) {
                                Text("SETTINGS_IPFS_ENABLE")
                                    .font(.headline)
                                    .offset(x: 0, y: Device.isMacOS ? -1 : 0)
                            }
                        }.padding(.vertical, .layer3)
                        
                        #if os(macOS)
                        Spacer()
                        #endif
                    }
                    
                    HStack(spacing: .layer2) {
                        Group {
                            if config.state.isIPFSAvailable == false {
                                Image(systemName: "xmark.circle")
                                    .font(.headline.bold())
                                    .foregroundColor(.red)
                                Text("IPFS_STATUS_OFFLINE")
                                    .font(.headline.bold())
                                    .foregroundColor(.red)
                            } else if config.state.enableIPFS {
                                Image(systemName: "checkmark.circle")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                Text("IPFS_STATUS_ONLINE")
                                    .font(.headline.bold())
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle.circle")
                                    .font(.headline.bold())
                                    .foregroundColor(Brand.Colors.yellow)
                                //TODO: localize
                                Text("Available")
                                    .font(.headline.bold())
                                    .foregroundColor(Brand.Colors.yellow)
                            }
                        }
                        .foregroundColor((config.state.isIPFSAvailable ? Color.green : Color.red).opacity(0.8))
                        
                        #if os(iOS)
                        Spacer()
                        #endif
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            setIPFSProperties()
                        } label: {
                            Text("MISC_EDIT")
                                .font(.headline.bold())
                                .foregroundColor(.foreground)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Color.background.opacity(0.75)
                                        .cornerRadius(4)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.leading, .layer3)
                        
                        #if os(macOS)
                        Spacer()
                        #endif
                    }
                    .padding(.bottom, .layer2)
                    
                    #if os(macOS)
                    Spacer()
                    #endif
                }
                .padding(.horizontal, .layer4)
                
                if config.state.isIPFSAvailable {
                    HStack {
                        Picker("", selection: config._state.ipfsContentType) {
                            //TODO: localize
                            Text("Markdown").tag(0)
                            //TODO: localize
                            Text("Classic").tag(1)
                            //TODO: localize
                            Text("Visualizer").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: Device.isExpandedLayout ? 240 : nil)
                        
                        if Device.isExpandedLayout {
                            Spacer()
                        }
                    }
                    .padding(.horizontal, .layer2)
                }
                
                if isTabSelected == true {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                        HStack {
                            Text("TITLE_GENERAL")
                                .font(.title2.bold())
                            
                            Spacer()
                        }
                    }
                    .padding(.top, .layer4)
                    .padding(.horizontal, .layer4)
                    ProfileSettingsView(showProfileSettings: false,
                                        modal: modal)
                }
                
                DebugSettingsView()
                    .graniteEvent(config.center.restart)
                
                Spacer()
                    .frame(height: 80)
                
                
                HStack(spacing: 4) {
                    Text("TITLE_OPEN_SOURCE")
                        .font(Fonts.live(.footnote, .regular))
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            if let url = URL(string: "https://github.com/neatia/Loom") {
                                openURL(url)
                            }
                        }
                    
                //TODO: For AppStore Release
//                    Text("MISC_PRIVACY_POLICY")
//                        .font(Fonts.live(.footnote, .regular))
//                        .foregroundColor(.accentColor)
//                        .onTapGesture {
////                            if let url = URL(string: "") {
////                                openURL(url)
////                            }
//                        }
//
//                    Text("//")
//                        .font(Fonts.live(.footnote, .regular))
//                        .foregroundColor(Brand.Colors.white)
//
//
//                    Text("MISC_TERMS_OF_USE")
//                        .font(Fonts.live(.footnote, .regular))
//                        .foregroundColor(.accentColor)
//                        .onTapGesture {
////                            if let url = URL(string: "") {
////                                openURL(url)
////                            }
//                        }
//
//                    Spacer()
                    #if os(macOS)
                    Spacer()
                    #endif
                }
                .frame(maxWidth: .infinity)
                .padding(.top, .layer4)
                .padding(.bottom, .layer2)
                .padding(.horizontal, .layer4)
                
//                HStack {
//                    Text("MISC_COPYRIGHT")
//                        .font(Fonts.live(.caption2, .regular))+Text(" Stoic Collective, LLC. \u{00A9} \(Calendar.current.component(.year, from: Date.now).asString.replacingOccurrences(of: ",", with: ""))")
//                        .font(Fonts.live(.caption2, .regular))
//
//                    Spacer()
//                }
//                .padding(.horizontal, .layer4)
//                .padding(.bottom, .layer5)
//                .foregroundColor(.foreground)
            }
        }
        .padding(.top, ContainerConfig.generalViewTopPadding)
        .addGraniteSheet(modal.sheetManager,
                         modalManager: modal.modalSheetManager,
                         background: Color.clear)
        .addGraniteModal(modal.modalManager)
    }
}
