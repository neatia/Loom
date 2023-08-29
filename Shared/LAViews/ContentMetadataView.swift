//
//  ContentMetadataView.swift
//  Loom
//
//  Created by PEXAVC on 8/5/23.
//

import SwiftUI
import LinkPresentation
import Granite
import UniformTypeIdentifiers
import ModerationKit

struct ContentMetadataView: View {
    @GraniteAction<Void> var showContent
    
    #if os(iOS)
    var backgroundColor: Color = Color(.systemGray5)
    #else
    var backgroundColor: Color = Color.black.opacity(0.5)
    #endif
    
    var meta: LPLinkMetadata?
    @State var image: GraniteImage?
    var urlToOpen: URL?
    var shouldLoad: Bool
    init(metadata: PageableMetadata?, urlToOpen: URL? = nil, shouldLoad: Bool = false) {
        self.meta = metadata?.linkMeta
        self._image = .init(initialValue: metadata?.imageThumb)
        self.urlToOpen = urlToOpen
        self.shouldLoad = shouldLoad && metadata == nil
    }
    
    var body: some View {
        largeType
    }
    
    @State private var isPresented: Bool = false
    @State var isLoaded: Bool = false
    
    @MainActor
    var largeType: some View {
        Button {
            #if os(iOS)
//            guard let url = meta?.url else { return }
//            if UIApplication.shared.canOpenURL(url) {
//                self.isPresented.toggle()
//            }
            showContent.perform()
            #else
            self.isPresented.toggle()
            #endif
        } label: {
            VStack(alignment: .leading, spacing: 0){
                ZStack(alignment: .bottomTrailing){
                    
                    if let image {
                        #if os(iOS)
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .scrollOnOverflow()
                            .frame(minHeight: (350 / image.size.width) * image.size.height)
                        #else
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .scrollOnOverflow()
                            .frame(minHeight: (350 / image.size.width) * image.size.height)
                        #endif
                    } else if let meta {
                        HStack {
                            HStack(spacing: 8){
                                VStack(alignment: .leading, spacing: 0){
                                    if let title = meta.title {
                                        Text(title)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.foreground)
                                            .lineLimit(3)
                                            .padding(.bottom, image == nil ? 0 : 4)
                                    }
                                    
                                    if let url = meta.url?.host {
                                        Text("\(url)")
                                            .foregroundColor(.secondaryForeground)
                                            .font(.footnote)
                                    }
                                }
                                
                                if image != nil {
                                    Spacer()
                                }
                                
                                else {
                                    Image(systemName: "arrow.up.forward.app.fill")
                                        .resizable()
                                        .foregroundColor(.secondaryForeground)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24, alignment: .center)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(backgroundColor)
                            )
                            Spacer()
                        }
                    }
                    
                }
            }
            .cornerRadius(12)
        }
        .buttonStyle(LinkButton())
        .task {
            guard shouldLoad else {
                return
            }
            
            //TODO: crash, when metadata has no thumb, but url is found
            await loadImage()
        }
        .universalWebCover(isPresented: $isPresented, url: urlToOpen ?? meta?.url)
    }
}

extension View {
    func universalWebCover(isPresented condition: Binding<Bool>,
                           url: URL?) -> some View {
        #if os(iOS)
        self.fullScreenCover(isPresented: condition) {
            if let url {
                SfSafariView(url: url)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        #else
        self.sheet(isPresented: condition) {
            if let url {
                PostContentView(url)
                    .frame(width: 600, height: 400)
            }
        }
        #endif
    }
}

struct LinkButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

extension ContentMetadataView {
    @MainActor
    func loadImage() async {
        guard let urlToOpen else {
            return
        }
        let provider = LPMetadataProvider()
        let metaData = try? await provider.startFetchingMetadata(for: urlToOpen)
        
        let type = String(describing: UTType.image)
        
        guard let imageProvider = metaData?.imageProvider else {
            return
        }
        
        if imageProvider.hasItemConformingToTypeIdentifier(type) {
            var thumb: GraniteImage? = nil
            guard let item = try? await imageProvider.loadItem(forTypeIdentifier: type) else {
                thumb = nil
                return
            }
            
            if thumb == nil,
               item is GraniteImage {
                thumb = item as? GraniteImage
            }
            
            if thumb == nil,
               item is URL {
                guard let url = item as? URL,
                      let data = try? Data(contentsOf: url) else { return }
                
                thumb = GraniteImage(data: data)
            }
            
            if thumb == nil,
               item is Data {
                guard let data = item as? Data else { return }
                
                thumb = GraniteImage(data: data)
            }
            
            if let thumb,
               PagerFilter.enableForNSFWExtended {
                let isNSFW = await ModerationKit.current.check(thumb, for: .nsfw)
                
                if !isNSFW {
                    self.image = thumb
                }
            } else {
                self.image = thumb
            }
        }
    }
}
