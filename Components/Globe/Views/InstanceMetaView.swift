//
//  InstanceMetaView.swift
//  Loom
//
//  Created by PEXAVC on 8/6/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import NukeUI
import MarkdownView
import FederationKit

struct InstanceMetaView: View {
    @Environment(\.graniteEvent) var restart
    
    var instance: FederatedInstance
    
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
        instance.domain
    }
    
    var subtitle: String? {
        instance.published.serverTimeAsDate?.timeAgoDisplay()
    }
    
    var isBase: Bool {
        instance.domain == FederationKit.host
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
    
    var host: String {
        instance.domain
    }
    
    @State var metadata: FederationMetadata?
    @State var siteMetaData: FederatedSiteMetadata?
    @State var task: Task<Void, Error>? = nil
    
    init(_ instance: FederatedInstance) {
        self.instance = instance
        
        if isBase {
            metadata = FederationKit.metadata()
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if Device.isExpandedLayout == false {
                connectView
            }
            
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
            .padding(.bottom, Device.isExpandedLayout ? .layer4 : .layer5)
            .padding(.horizontal, .layer4)
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
            
            Divider()
                .padding(.top, Device.isMacOS ? .layer2 : 0)
            
            if let sidebar {
                MarkdownView(text: sidebar)
                    .markdownViewRole(.editor)
                    .padding(.layer3)
                    .background(Color.secondaryBackground)
                    .cornerRadius(8)
                    .padding(.layer3)
            }
            
            LocalCommunityPreview(url: host)
            
            if Device.isExpandedLayout {
                connectView
            }
            
            Spacer()
        }
        .task {
            await getMetadata()
        }
    }
    
    func getMetadata() async {
        guard let response = await Federation.metadata(url: host) else { return }
        self.siteMetaData = response
    }
    
    var connectView: some View {
        Button {
            GraniteHaptic.light.invoke()
            restart?.send(ConfigService.Restart.Meta(accountMeta: nil, host: host))
        } label: {
            Text("MISC_CONNECT")
                .font(.headline.bold())
                .lineLimit(1)
                .foregroundColor(Color.black)
                .padding(.horizontal, .layer2)
                .padding(.vertical, .layer1)
                .background(RoundedRectangle(cornerRadius: .layer2)
                    .fill(Brand.Colors.yellow))
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, .layer5)
    }
}

struct InstanceMetaDetailsView: View {
    var meta: FederationMetadata
    
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

