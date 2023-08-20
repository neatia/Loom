//
//  Snapshot.swift
//  Loom (macOS)
//
//  Created by Ritesh Pakala on 8/19/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import LemmyKit
import UIKit

extension View {
    func snapshot() -> UIImage {
        
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = UIColor(Color.background)

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

extension PostCardView {
    static func snapshot(model: PostView, metadata: PageableMetadata?) -> UIImage {
        PostCardView()
            .contentContext(.init(postModel: model))
            .environment(\.pagerMetadata, metadata)
            .snapshot()
    }
}

public struct ShareModal<Content: View>: View {
    
    @State var isScreenshotting: Bool = false
    
    var urlString: String? = nil
    var content: () -> Content
    init(urlString: String? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self.urlString = urlString
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ScreenshotView($isScreenshotting) {
                    content()
                }
                .fixedSize(horizontal: false, vertical: true)
                .cornerRadius(8)
            }
            
            Spacer()
            
            HStack(spacing: .layer3) {
                Spacer()
                
                Button {
                    GraniteHaptic.light.invoke()
                    isScreenshotting = true
                } label: {
                    Image(systemName: "photo")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                
                if let urlString {
                    Button {
                        GraniteHaptic.light.invoke()
                        ModalService.share(urlString: urlString)
                    } label: {
                        Image(systemName: "link")
                            .font(.title2)
                            .scaleEffect(x: -1, y: 1)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            
            Spacer()
        }
    }
}


public struct ScreenshotView<Content: View> : GenericViewRepresentable {
    
    @Binding var isScreenshotting: Bool
    var content: () -> Content
    public init(_ isScreenshotting: Binding<Bool>,
                @ViewBuilder content: @escaping () -> Content) {
        self._isScreenshotting = isScreenshotting
        self.content = content
    }
    
    #if os(iOS)
    public func makeUIView(context: Context) -> UIView {
        
        let controller = UIHostingController(rootView: content())
        let view = controller.view
        
        return view ?? .init()
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        guard isScreenshotting else { return }
        isScreenshotting = false
        
        let renderer = UIGraphicsImageRenderer(size: uiView.frame.size)

        let image = renderer.image { _ in
            uiView.drawHierarchy(in: uiView.bounds, afterScreenUpdates: true)
        }
        
        ModalService
            .share(image: image)
    }
    #else
    public func makeNSView(context: GenericControllerRepresentableContext<UIView>) -> SCNView {
        
        scene.setup(data, force: data.isEmpty)
        
        return scene.sceneView
    }

    public func updateNSView(_ scnView: SCNView, context: Context) {
        if data.isNotEmpty {
            scene.setup(data)
        }
    }
    #endif
}
