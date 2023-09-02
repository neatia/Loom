//
//  ShareModal.swift
//  Loom
//
//  Created by PEXAVC on 8/20/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI


#if os(macOS)
import AppKit
#endif

public struct ShareModal<Content: View>: View {
    @Environment(\.contentContext) var context
    
    @State var isScreenshotting: Bool = false
    
    #if os(macOS)
    @State var image: NSImage? = nil
    #endif
    
    var urlString: String? = nil
    var content: () -> Content
    init(urlString: String? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self.urlString = urlString
        self.content = content
    }
    
    public var body: some View {
        GraniteStandardModalView(fullWidth: Device.isMacOS) {
            HStack(spacing: .layer4) {
                Text("MISC_SHARE")
                    .font(.title.bold())
                
                Spacer()
                

                #if os(iOS)
                Button {
                    GraniteHaptic.light.invoke()
                    isScreenshotting = true
                } label: {
                    Image(systemName: "photo")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .padding(.trailing, .layer1)
                
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
                #endif
                
            }
        } content: {
            shareMainView
        }
    }
    var shareMainView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ScreenshotView($isScreenshotting,
                                   encodeMessage: urlString) {
                        content()
                    }
                    .frame(maxWidth: Device.isExpandedLayout ? (ContainerConfig.iPhoneScreenWidth * 0.9) : nil)
                    .cornerRadius(12)
                }
            }
            .frame(maxHeight: Device.isExpandedLayout ? 400 : nil)
            
            
            #if os(macOS)
            Spacer()
            HStack(spacing: 0) {
                Spacer()
                
                sharingOptions

                Spacer()
            }
            .padding(.top, Device.isMacOS ? .layer5 : 0)
            Spacer()
            #endif
            
        }
    }
    
    #if os(macOS)
    var sharingOptions: some View {
        Group {
            Menu {
                ForEach(
                    NSSharingService
                        .sharingServices(forItems: [""]), id: \.title ) { item in
                    Button {
                        if let commentView = context.commentModel {
                            var text: String = commentView.comment.content
                            text += "\n\n\(commentView.comment.ap_id)"
                            item.perform(withItems: [text])
                        } else if let postView = context.postModel {
                            var text: String = postView.post.name
                            if let body = postView.post.body {
                                text += "\n\n\(body)"
                            }
                            text += "\n\n\(postView.post.ap_id)"
                            item.perform(withItems: [text])
                        }
                    } label: {
                        Image(nsImage: item.image)
                        Text(item.title)
                    }
                }
            } label: {
                Image(systemName: "link")
                    .font(.title2)
                    .contentShape(Rectangle())
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .frame(width: 30)
        }
    }
    #endif
}
