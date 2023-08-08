//
//  PostContentView.swift
//  Loom
//
//  Created by PEXAVC on 7/17/23.
//

import Foundation
import Granite
import SwiftUI
import NukeUI
import LemmyKit

enum PostContentKind {
    case webPage(URL)
    case image(URL)
    case text
    
    static func from(_ urlString: String?) -> PostContentKind {
        guard let urlString else { return .text }
        
        guard let url = URL(string: urlString) else {
            return .text
        }
        
        if url.lastPathComponent.contains(".") && url.lastPathComponent.contains(".html") == false {
            return .image(url)
        } else {
            return .webPage(url)
        }
    }
    
    var isWebPage: Bool {
        switch self {
        case .webPage:
            return true
        default:
            return false
        }
    }
}

struct PostContentView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var postView: PostView?
    
    @Environment(\.openURL) var openURL
    
    @State var action = WebViewAction.idle
    @State var webState = WebViewState.empty
    @State var contentKind: PostContentKind
    
    var fullPage: Bool = false
    
    init(postView: PostView) {
        self.postView = postView
        _contentKind = .init(initialValue: PostContentKind.from(postView.post.url))
    }
    
    init(_ url: URL) {
        _contentKind = .init(initialValue: .webPage(url))
        fullPage = true
    }
    
    var body: some View {
        VStack {
            if fullPage == false {
                Spacer()
            }
            
            ZStack {
                #if os(iOS)
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(.background)
                    .edgesIgnoringSafeArea(.all)
                #endif
                
                VStack {
                    switch contentKind {
                    case .webPage(let url):
                        GraniteWebView(action: $action,
                                       state: $webState,
                                       restrictedPages: ["apple.com"],
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
                    case .text:
                        EmptyView()
                    }
                }
                .padding(.layer5)
            }
            .frame(maxHeight: 600)
            
            if fullPage {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Close")
                        .font(.title3)
                        .foregroundColor(.foreground)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, .layer4)
            }
        }
        .task {
//            switch contentKind {
//            case .webPage(let url):
//                analyze.center.load.send(AnalyzeService.Load.Meta(url: url.absoluteString))
//            default:
//                break
//            }
        }
        .onAppear {
            guard contentKind.isWebPage else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                switch contentKind {
                case .webPage(let url):
                    action = .load(URLRequest(url: url))
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
