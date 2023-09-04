import Granite
import GraniteUI
import SwiftUI
import Foundation
import MarbleKit

extension Settings: View {
    var aboutPageLinkString: String {
        ""
    }
    
    public var view: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: .layer4) {
                VStack {
                    Spacer()
                    Text("TITLE_SETTINGS")
                        .font(.title.bold())
                }
                
                Spacer()
            }
            .frame(height: 24)
            .padding(.bottom, .layer5)
            .padding(.leading, .layer4)
            .padding(.trailing, .layer4)
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                ProfileSettingsView(showProfileSettings: false,
                                    offline: true)
                    .padding(.top, .layer4)
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    HStack {
                        Group {
                            //TODO: Localize
                            Text("Filtering")
                                .font(.title2.bold())
                        }
                        //TODO: Localize
                        .addInfoIcon(text: "Filter content via various offline inference strategies and/or keywords.")
                        
                        Spacer()
                    }
                    .padding(.vertical, .layer4)
                    .padding(.horizontal, .layer4)
                    
                    Divider()
                        .padding(.bottom, .layer2)
                        .padding(.leading, .layer4)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Toggle(isOn: config._state.extendedNSFWFilterEnabled) {
                                //TODO: localize
                                Text("NSFW Extended")
                                    .font(.body)
                                    .offset(x: 0, y: Device.isMacOS ? -1 : 0)
                            }
                        }.padding(.vertical, .layer3)
                        
#if os(macOS)
                        Spacer()
#endif
                    }
                    .padding(.horizontal, .layer4)
                    
                    HStack {
                        Toggle(isOn: config._state.keywordsFilterEnabled) {
                            //TODO: localize
                            Text("Keywords")
                                .font(.body)
                                .offset(x: 0, y: Device.isMacOS ? -1 : 0)
                        }
                        
#if os(macOS)
                        Spacer()
#endif
                    }
                    .padding(.vertical, .layer2)
                    .padding(.horizontal, .layer4)
                    
                    FilterKeywordCollectionView(config: config.state.keywordsFilter)
                        .attach({ keywordToEdit in
                            ModalService
                                .shared
                                .presentSheet {
                                
                                FilterKeywordView(keywordToEdit: keywordToEdit)
                                        .attach({ keyword in
                                            var keywords: [FilterConfig.Keyword] = config.state.keywordsFilter.keywords
                                            keywords.removeAll(where: { $0.value.lowercased() == keyword.value.lowercased() })
                                            
                                            let filterConfig: FilterConfig = .init(keywords: keywords)
                                            config._state.keywordsFilter.wrappedValue = filterConfig
                                            if config.state.keywordsFilterEnabled {
                                                PagerFilter.filterKeywords = filterConfig
                                            }
                                            DispatchQueue.main.async {
                                                ModalService.shared.dismissSheet()
                                            }
                                        }, at: \.remove)
                                        .attachAndClear({ keyword in
                                            var keywords: [FilterConfig.Keyword] = config.state.keywordsFilter.keywords
                                            
                                            if let index = keywords.firstIndex(where: { $0.value.lowercased() == keyword.value.lowercased() }) {
                                                keywords[index] = keyword
                                            } else {
                                                keywords.insert(keyword, at: 0)
                                            }
                                            
                                            let filterConfig: FilterConfig = .init(keywords: keywords)
                                            
                                            config._state.keywordsFilter.wrappedValue = filterConfig
                                            if config.state.keywordsFilterEnabled {
                                                PagerFilter.filterKeywords = filterConfig
                                            }
                                            DispatchQueue.main.async {
                                                ModalService.shared.dismissSheet()
                                            }
                                        }, at: \.save)
                            }
                        }, at: \.addKeyword)
                        .padding(.horizontal, .layer4)
                        .padding(.top, .layer2)
                }
                .padding(.bottom, .layer4)
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    HStack {
                        Group {
                            //TODO: Localize
                            Text("Feed")
                                .font(.title2.bold())
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, .layer4)
                    .padding(.horizontal, .layer4)
                    
                    Divider()
                        .padding(.bottom, .layer2)
                        .padding(.leading, .layer4)
                    
                
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Toggle(isOn: config._state.manuallyFetchMoreContent) {
                                //TODO: localize
                                Text("Manually fetch more content")
                                    .font(.body)
                                    .offset(x: 0, y: Device.isMacOS ? -1 : 0)
                            }
                        }.padding(.vertical, .layer3)
                        
    #if os(macOS)
                        Spacer()
    #endif
                    }
                    .padding(.horizontal, .layer4)
                    
                
                    VStack {
                        HStack {
                            //TODO: localize
                            Text("Style")
                                .font(.body)
                                .offset(x: 0, y: Device.isMacOS ? -1 : 0)
                            
                            Spacer()
                        }
                        .padding(.horizontal, .layer4)
                        HStack {
                            Picker("", selection: config._state.feedStyle) {
                                //TODO: localize
                                Text("Social").tag(FeedStyle.style2)
                                //TODO: localize
                                Text("Reader").tag(FeedStyle.style3)
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: Device.isExpandedLayout ? 240 : nil)
                            
                            if Device.isExpandedLayout {
                                Spacer()
                            }
                        }
                        .padding(.horizontal, .layer2)
                        .padding(.leading, .layer2)
                    }
                }
                .padding(.bottom, .layer4)
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    HStack {
                        Group {
                            //TODO: Localize
                            Text("Marble")
                                .font(.title2.bold())
                        }
                        //TODO: Localize
                        .addInfoIcon(text: "Adds an interactive experience to various types of content.")
                        
                        Spacer()
                    }
                    .padding(.vertical, .layer4)
                    .padding(.horizontal, .layer4)
                    
                    Divider()
                        .padding(.bottom, .layer2)
                        .padding(.leading, .layer4)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Toggle(isOn: config._state.marbleYoutubeLinks) {
                                //TODO: localize
                                Text("Youtube links")
                                    .font(.body)
                                    .offset(x: 0, y: Device.isMacOS ? -1 : 0)
                            }
                        }.padding(.vertical, .layer3)
                        
                        #if os(macOS)
                        Spacer()
                        #endif
                    }
                    .padding(.horizontal, .layer4)
                    
                    
                    if config.state.marbleYoutubeLinks {
                        ScrollView([.horizontal], showsIndicators: false) {
                            Picker("", selection: config._state.marbleFX) {
                                ForEach(MarbleWebGLCatalog.FX.allCases) { fx in
                                    Text("\(fx.rawValue.capitalized)")
                                        .tag(fx)
                                }
                            }
                            .pickerStyle(.segmented)
                            //Also helps for detecting scroll gesture
                            .padding(.top, .layer3)
                        }
                        .padding(.horizontal, .layer2)
                        .padding(.leading, .layer2)
                    }
                    
                    /*
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Toggle(isOn: config._state.marblePlaybackControls) {
                                //TODO: localize
                                Text("Playback controls")
                                    .font(.body)
                                    .offset(x: 0, y: Device.isMacOS ? -1 : 0)
                            }
                        }
                        
                        #if os(macOS)
                        Spacer()
                        #endif
                    }
                    .padding(.trailing, .layer4)
                     */
                    
                    #if os(macOS)
                    Spacer()
                    #endif
                }
                .padding(.bottom, .layer4)
                
                //IPFS Settings
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    HStack {
                        Group {
                            Text("MISC_IPFS")
                                .font(.title2.bold())+Text(" (Infura)")
                                .font(.title2.bold())
                        }
                            .addInfoIcon(text: "IPFS_INFO_TEMP")
                        
                        Spacer()
                    }
                    .padding(.vertical, .layer4)
                    .padding(.trailing, .layer4)
                    
                    Divider()
                        .padding(.bottom, .layer2)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Toggle(isOn: config._state.enableIPFS) {
                                Text("SETTINGS_IPFS_ENABLE")
                                    .font(.body)
                                    .offset(x: 0, y: Device.isMacOS ? -1 : 0)
                            }
                        }.padding(.vertical, .layer3)
                        
                        #if os(macOS)
                        Spacer()
                        #endif
                    }
                    .padding(.trailing, .layer4)
                    
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
                                .font(.body)
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
                    .padding(.trailing, .layer4)
                    
                }
                .padding(.leading, .layer4)
                .padding(.bottom, config.state.isIPFSAvailable ? .layer3 : nil)
                
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
                    .padding(.bottom, .layer4)
                    .padding(.leading, .layer2)
                }
                
                #if os(macOS)
                Spacer()
                #endif
                    
                //Debug Settings
                DebugSettingsView()
                    //.graniteEvent(config.center.restart)
                
                Spacer()
                    .frame(height: 60)
                
                
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
                .padding(.vertical, .layer4)
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
        .background(Color.background)
        .padding(.top, Device.isMacOS ? ContainerConfig.generalViewTopPadding : 0)
    }
    
}

