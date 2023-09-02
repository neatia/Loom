import Granite
import GraniteUI
import SwiftUI
import FederationKit

extension Write: View {
    public var view: some View {
        VStack(spacing: 0) {
            HStack(spacing: .layer3) {
//                #if os(macOS)
//                Image(systemName: "arrow.up.left.and.arrow.down.right")
//                    .font(.headline)
//                    .route(style: .init(size: .init(width: 800, height: 400),
//                                        styleMask: .resizable)) {
//                        Write(kind: .full)
//                    }
//                #endif
                
                Button {
                    GraniteHaptic.light.invoke()
                    setPostURL()
                } label : {
                    Image(systemName: "\(state.postURL.isNotEmpty ? "link" : "link.badge.plus")")
                        .font(.title3)
                        .foregroundColor(postURLColorState)
                        .scaleEffect(.init(width: -1, height: 1))
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    GraniteHaptic.light.invoke()
                    importPicture()
                } label : {
                    Image(systemName: "\(state.imageData != nil ? "photo" : "rectangle.center.inset.filled.badge.plus")")
                        .font(.title3)
                        .foregroundColor(imageColorState)
                }
                .buttonStyle(PlainButtonStyle())
                .onChange(of: state.imageData) { data in
                    guard let data, config.state.enableIPFS == false else { return }
                    
                    _ = Task.detached {
                        let response = await Federation.uploadImage(data)
                        
                        guard let response else {
                            //Most likely file too big
                            //TODO: error toast
                            return
                        }
                        
                        let userContent: UserContent = .init(media: response)
                        _state.imageContent.wrappedValue = userContent
                        if state.postURL.isEmpty {
                            _state.postURL.wrappedValue = userContent.contentURL
                        }
                    }
                }
                
                if state.imageData != nil {
                    Button {
                        GraniteHaptic.light.invoke()
                        
                        _ = Task.detached {
                            
                            if let content = state.imageContent {
                                let response = await Federation.deleteImage(content.media)
                            }
                            
                            _state.imageData.wrappedValue = nil
                            _state.imageContent.wrappedValue = nil
                            _state.postURL.wrappedValue = ""
                        }
                    } label : {
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundColor(Color.red)
                            .opacity(0.8)
                            .offset(y: -1)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
//                Toggle(isOn: _state.enableMDPreview) {
//                    Text("MISC_PREVIEW")
//                        .font(.headline)
//                        .offset(x: 0, y: Device.isMacOS ? -1 : 0)
//                }
//                .frame(width: Device.isMacOS ? 100 : 140)
                
                Spacer()
                
                if state.isPosting {
                    StandardProgressView()
                } else {
                    
                    if state.isPosting == false && state.isEditing == false {
                        Button {
                            GraniteHaptic.light.invoke()
                            setCommunity()
                        } label : {
                            if let communityView = state.postCommunity {
                                Text(communityView.community.name)
                                    .font(.headline.bold())
                                    .offset(x: 0, y: -1)
                            } else if Device.isMacOS {
                                Text("TITLE_SET_COMMUNITY")
                                    .font(.headline.bold())
                                    .offset(x: 0, y: -1)
                            }
                            if let communityView = state.postCommunity {
                                AvatarView(communityView.iconURL, size: .mini, isCommunity: true)
                            } else {
                                Image(systemName: "globe")
                                    .font(.title3)
                                    .contentShape(Rectangle())
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(state.postCommunity != nil ? .foreground : .red)
                        .opacity(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Button {
                        guard state.isPosting == false else {
                            return
                        }
                        
                        GraniteHaptic.light.invoke()
                        _state.isPosting.wrappedValue = true
                        _state.routerId.wrappedValue = router.id
                        center.create.send()
                    } label: {
                        Image(systemName: state.isEditing ? "sdcard.fill" : "paperplane.fill")
                            .font(state.isEditing ? .title3 : .headline)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(height: 24)
            .padding(.leading, .layer4)
            .padding(.trailing, .layer4)
            .padding(.bottom, .layer4)
            
            Divider()
                .padding(.bottom, state.imageContent == nil ? .layer2 : 0)
            
            if let url = state.imageContent {
                HStack(spacing: .layer2) {
                    if state.enableImagePreview {
                        Spacer()
                        ScrollView(showsIndicators: false) {
                            LinkPreview(url: URL(string: url.contentURL))
                                .frame(maxWidth: 200)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: .layer2) {
                        Spacer()
                        Button {
                            GraniteHaptic.light.invoke()
                            _state.enableImagePreview.wrappedValue.toggle()
                        } label : {
                            Image(systemName: state.enableImagePreview ? "minus.square.fill" : "arrow.up.and.down.square.fill")
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if state.enableImagePreview {
                            Button {
                                GraniteHaptic.light.invoke()
                                guard let content = state.imageContent else { return }
                                
                                _ = Task.detached {
                                    
                                    let response = await Federation.deleteImage(content.media)
                                    
                                    _state.imageData.wrappedValue = nil
                                    _state.imageContent.wrappedValue = nil
                                    _state.postURL.wrappedValue = ""
                                }
                            } label : {
                                Image(systemName: "trash")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, .layer1)
                        }
                        Spacer()
                    }
                }
                .padding(.layer3)
                .padding(.horizontal, .layer2)
                .frame(maxHeight: state.enableImagePreview ? 200 : 48)
                
                Divider()
                    .padding(.bottom, .layer2)
            }
            
            WriteView(kind: self.kind,
                      title: _state.title,
                      content: _state.content)
        }
        .addGraniteSheet(id: Write.modalId,
                         modal.sheetManager,
                         background: Color.clear)
        .padding(.top, .layer4)
        .background(Device.isIPhone ? .clear : Color.background)
        .onAppear {
            #if os(iOS)
            UITextView.appearance().backgroundColor = .clear
            #endif
        }
    }
}
