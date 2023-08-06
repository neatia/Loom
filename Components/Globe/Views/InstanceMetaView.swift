//
//  InstanceMetaView.swift
//  Lemur
//
//  Created by Ritesh Pakala on 8/6/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import LemmyKit
import MarkdownView
import NukeUI

struct InstanceMetaView: View {
    var node: Node
    
    var name: String? {
        if isBase {
            return metadata?.site.name
        } else {
            return siteMetaData?.title
        }
    }
    
    var sidebar: String? {
        if isBase {
            return metadata?.site.sidebar
        } else {
            return siteMetaData?.description
        }
    }
    
    var title: String {
        node.meta.title
    }
    
    var subtitle: String? {
        node.meta.subtitle
    }
    
    var isBase: Bool {
        node.style.isMain && LemmyKit.auth != nil
    }
    
    var iconURL: URL? {
        if let metadata, let icon = metadata.site.icon {
            return .init(string: icon)
        } else {
            return nil
        }
    }
    
    var bannerURL: URL? {
        if let metadata, let banner = metadata.site.banner {
            return .init(string: banner)
        } else if let banner = siteMetaData?.image {
            return .init(string: banner)
        } else {
            return nil
        }
    }
    
    @State var metadata: Lemmy.Metadata?
    @State var siteMetaData: SiteMetadata?
    @State var task: Task<Void, Error>? = nil
    
    init(node: Node) {
        self.node = node
        
        if isBase {
            metadata = LemmyKit.current.metadata
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: .layer4) {
                if let iconURL {
                    AvatarView(iconURL)
                }
                VStack {
                    Spacer()
                    if let name {
                        HStack {
                            Text(name)
                                .font(.title.bold())
                            Spacer()
                        }
                    }
                    HStack {
                        Text(title)
                            .font(.title3)
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .frame(height: bannerURL != nil ? 62 : 36)
            .background(Color.background.overlayIf(bannerURL != nil) {
                Group {
                    if let url = bannerURL {
                        LazyImage(url: url) { state in
                            if let image = state.image {
                                image
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                                //menu + header + titlebar
                            } else {
                                Color.clear
                            }
                        }.allowsHitTesting(false)
                    } else {
                        EmptyView()
                    }
                }
            }.clipped())
            .padding(.vertical, Device.isExpandedLayout ? .layer4 : .layer5)
            .padding(.horizontal, .layer4)
            
            Divider()
                .padding(.top, Device.isMacOS ? .layer2 : 0)
            
            if let sidebar {
                MarkdownView(text: sidebar)
                    .markdownViewRole(.editor)
                    .padding(.layer3)
                    .background(Color.tertiaryBackground)
                    .cornerRadius(8)
                    .padding(.layer3)
            }
            
            LocalCommunityPreview(url: "https://" + title)
            
            Spacer()
        }
        .onChange(of: metadata) { newValue in
//            self.task?.cancel()
//            self.task = Task {
//                await getMetadata()
//            }
        }
        .task {
            await getMetadata()
        }
    }
    
    func getMetadata() async {
        if isBase {
            metadata = LemmyKit.current.metadata
        } else {
            guard let response = await Lemmy.metadata(url: "https://" + title) else { return }
            self.siteMetaData = response.metadata
        }
    }
    
    func getLocalCommunities() async {
        
    }
}

struct InstanceMetaDetailsView: View {
    var meta: Lemmy.Metadata
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if let description = meta.site.description {
                    Text(description)
                }
                Spacer()
            }
            
            HStack {
                Spacer()
            }
        }
    }
}

extension Lemmy.Metadata: Equatable {
    public static func == (lhs: Lemmy.Metadata,
                           rhs: Lemmy.Metadata) -> Bool {
        lhs.site.id == rhs.site.id
    }
}
