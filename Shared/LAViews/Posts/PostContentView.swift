//
//  PostContentView.swift
//  Loom
//
//  Created by PEXAVC on 7/17/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import NukeUI
import FederationKit

enum PostContentKind {
    case webPage(URL)
    case webPageHTML(String, URL)
    case image(URL)
    case text
    
    static func from(urlString: String?) -> PostContentKind {
        guard let urlString else { return .text }
        
        guard let url = URL(string: urlString) else {
            return .text
        }
        
        return PostContentKind.from(url: url)
    }
    
    static func from(url: URL) -> PostContentKind {
        if MarbleOptions.enableFX,
           let youtubeId = url.absoluteString.youtubeID {
            return .webPageHTML(Write.Generate.shader(title: "Loom Render", author: "pexavc", content: youtubeId, urlString: url.absoluteString, image_url: ""), url)
        } else if url.lastPathComponent.contains(".") && url.lastPathComponent.contains(".html") == false {
            return .image(url)
        } else {
            return .webPage(url)
        }
    }
    
    var isWebPage: Bool {
        switch self {
        case .webPage, .webPageHTML:
            return true
        default:
            return false
        }
    }
}

struct PostContentView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var postView: FederatedPostResource?
    
    @Environment(\.openURL) var openURL
    
    @State var action = WebViewAction.idle
    @State var webState = WebViewState.empty
    @State var contentKind: PostContentKind
    
    var fullPage: Bool = false
    
    init(postView: FederatedPostResource) {
        self.postView = postView
        _contentKind = .init(initialValue: PostContentKind.from(urlString: postView.post.url))
    }
    
    init(_ url: URL, fullPage: Bool = true) {
        _contentKind = .init(initialValue: PostContentKind.from(url: url))
        self.fullPage = fullPage
    }
    
    var body: some View {
        VStack {
            if fullPage == false && !Device.isIPhone {
                Spacer()
            }
            
            ZStack {
#if os(iOS)
                
                RoundedRectangle(cornerRadius: Device.isIPhone ? 0 : 16)
                    .foregroundColor(Color.background)
                    .edgesIgnoringSafeArea(.all)
                #endif
                
                VStack {
                    switch contentKind {
                    case .webPage, .webPageHTML:
                        GraniteWebView(action: $action,
                                       state: $webState,
                                       restrictedPages: [],
                                       htmlInState: true)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 8)
                        )
                    case .image(let url):
                        LazyImage(url: url) { state in
                            if let image = state.imageContainer?.image {
                                PhotoView(image: image)
                                    .background(Color.foreground.opacity(0.25))
                            } else {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.foreground.opacity(0.25))
                                    Image(systemName: "photo")
                                        .font(.title3)
                                        .foregroundColor(.foreground)
                                }
                            }
                        }
                        .cornerRadius(8.0)
                        .clipped()
                        .contentShape(Rectangle())
                    case .text:
                        EmptyView()
                    }
                }
                .padding(.layer5)
            }
            .frame(maxHeight: Device.isIPhone ? nil : 600)
            
            if fullPage {
                Button {
                    GraniteHaptic.light.invoke()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.foreground)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, .layer4)
            }
        }
        .onAppear {
            guard contentKind.isWebPage else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                switch contentKind {
                case .webPage(let url):
                    action = .load(URLRequest(url: url))
                case .webPageHTML(let html, let url):
                    action = .loadHTML(html, url)
                default:
                    break
                }
            }
        }
    }
}

import SwiftUI

struct PhotoView: View {
    
    @State var scale: CGFloat = 1
    @State var scaleAnchor: UnitPoint = .center
    @State var lastScale: CGFloat = 1
    @State var offset: CGSize = .zero
    @State var lastOffset: CGSize = .zero
    @State var debug = ""
    
    let image: GraniteImage
    
    var body: some View {
        GeometryReader { geometry in
            let magnificationGesture = MagnificationGesture()
                .onChanged{ gesture in
                    scaleAnchor = .center
                    scale = lastScale * gesture
                }
                .onEnded { _ in
                    fixOffsetAndScale(geometry: geometry)
                }
            
            let dragGesture = DragGesture()
                .onChanged { gesture in
                    var newOffset = lastOffset
                    newOffset.width += gesture.translation.width
                    newOffset.height += gesture.translation.height
                    offset = newOffset
                }
                .onEnded { _ in
                    fixOffsetAndScale(geometry: geometry)
                }
            
            #if os(iOS)
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .position(x: geometry.size.width / 2,
                          y: geometry.size.height / 2)
                .scaleEffect(scale, anchor: scaleAnchor)
                .offset(offset)
                .gesture(dragGesture)
                .gesture(magnificationGesture)
            #else
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .position(x: geometry.size.width / 2,
                          y: geometry.size.height / 2)
                .scaleEffect(scale, anchor: scaleAnchor)
                .offset(offset)
                .gesture(dragGesture)
                .gesture(magnificationGesture)
            
            #endif
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func fixOffsetAndScale(geometry: GeometryProxy) {
        let newScale: CGFloat = .minimum(.maximum(scale, 1), 4)
        let screenSize = geometry.size
        
        let originalScale = image.size.width / image.size.height >= screenSize.width / screenSize.height ?
            geometry.size.width / image.size.width :
            geometry.size.height / image.size.height
        
        let imageWidth = (image.size.width * originalScale) * newScale
        
        var width: CGFloat = .zero
        if imageWidth > screenSize.width {
            let widthLimit: CGFloat = imageWidth > screenSize.width ?
                (imageWidth - screenSize.width) / 2
                : 0

            width = offset.width > 0 ?
                .minimum(widthLimit, offset.width) :
                .maximum(-widthLimit, offset.width)
        }
        
        let imageHeight = (image.size.height * originalScale) * newScale
        var height: CGFloat = .zero
        if imageHeight > screenSize.height {
            let heightLimit: CGFloat = imageHeight > screenSize.height ?
                (imageHeight - screenSize.height) / 2
                : 0

            height = offset.height > 0 ?
                .minimum(heightLimit, offset.height) :
                .maximum(-heightLimit, offset.height)
        }
        
        let newOffset = CGSize(width: width, height: height)
        lastScale = newScale
        lastOffset = newOffset
        withAnimation() {
            offset = newOffset
            scale = newScale
        }
    }
}
