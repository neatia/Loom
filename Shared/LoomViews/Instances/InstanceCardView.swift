//
//  InstanceCardView.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/9/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import NukeUI
import LemmyKit
import MarkdownView

//TODO: A caching service for any type of data
//should incorporate link previews, images in other views etc
//Basic Caching:
class InstanceDetailsCache {
    static var shared: InstanceDetailsCache = .init()
    
    var cache: [String : SiteView] = [:]
}

struct InstanceCardView: View {
    @Environment(\.graniteEvent) var restart
    
    @GraniteAction<Instance> var connect
    @GraniteAction<Instance> var favorite
    
    @State var metadata: Lemmy.Metadata?
    @State var siteMetaData: SiteMetadata?
    @State var ping: TimeInterval? = nil
    
    let instance: Instance
    let client: Lemmy
    
    var host: String {
        "https://" + instance.domain
    }
    
    var sidebar: String? {
        metadata?.site.sidebar
    }
    
    var title: String {
        metadata?.site.name ?? instance.domain.host
    }
    
    var subtitle: String? {
        instance.published.serverTimeAsDate?.timeAgoDisplay()
    }
    
    var isBase: Bool {
        instance.domain == LemmyKit.host
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
    
    var hasBanner: Bool {
        bannerURL != nil
    }
    
    var isConnected: Bool
    var isFavorite: Bool
    
    init(_ instance: Instance, isConnected: Bool = false, isFavorite: Bool = false) {
        self.instance = instance
        self.isConnected = isConnected
        self.isFavorite = isFavorite
        self.client = .init(apiUrl: instance.domain)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                VStack(spacing: hasBanner ? .layer1 : 0) {
                    HStack {
                        Text(title)
                            .foregroundColor(.foreground)
                            .font(.headline.bold())
                            .textReadabilityIf(hasBanner)
                        Spacer()
                    }
                    
                    if metadata != nil {
                        HStack {
                            Text(instance.domain)
                                .foregroundColor(.foreground)
                                .font(.caption)
                                .textReadabilityIf(hasBanner)
                            Spacer()
                        }
                    }
                }
                
                Spacer()
                
                AvatarView(iconURL, size: .mini)
            }
            .padding(.leading, .layer3)
            .padding(.trailing, .layer2)
            .padding(.top, hasBanner || sidebar != nil ? .layer2 : .layer1)
            
            
            if let sidebar {
                ScrollView {
                    MarkdownView(text: sidebar)
                        .markdownViewRole(.editor)
                        .padding(.layer3)
                }
                .frame(maxHeight: 100)
                .background(Color.tertiaryBackground)
                .cornerRadius(8)
                .padding(.horizontal, .layer3)
                .padding(.top, .layer2)
                .fixedSize(horizontal: false, vertical: true)
            }
            
            Divider()
                .padding(.vertical, .layer2)
            
            HStack(spacing: .layer3) {
                Button {
                    GraniteHaptic.light.invoke()
                    connect.perform(instance)
                    restart?.send(ConfigService.Restart.Meta(accountMeta: nil, host: host))
                } label: {
                    if isConnected {
                        //TODO: localize
                        Text("Connected")
                            .foregroundColor(Brand.Colors.black)
                            .font(.headline.bold())
                    } else {
                        Text("MISC_CONNECT")
                            .foregroundColor(Brand.Colors.black)
                            .font(.headline.bold())
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, .layer3)
                .padding(.vertical, .layer1)
                .background(RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(isConnected ? Brand.Colors.purple : Brand.Colors.yellow))
                .padding(.bottom, .layer2)
                
                
                Button {
                    GraniteHaptic.light.invoke()
                    favorite.perform(instance)
                } label: {
                    Image(systemName: "star\(isFavorite ? ".fill" : "")")
                        .foregroundColor(isFavorite ? Brand.Colors.yellow : .foreground)
                }
                .buttonStyle(.plain)
                .textReadabilityIf(hasBanner)
                .padding(.bottom, .layer2)
                
                Spacer()
                
                PingBars(time: ping ?? 0, isDisconnected: ping == nil)
                    .textReadabilityIf(hasBanner)
                    .padding(.bottom, 6)
            }
            .padding(.horizontal, .layer3)
            .padding(.vertical, hasBanner == false && sidebar != nil ? .layer1 : 0)
        }
        .frame(minWidth: 200, minHeight: 100)
        .background(
        RoundedRectangle(cornerRadius: 8.0)
            .stroke(Color.secondaryForeground.opacity(0.75), lineWidth: 1.0)
            .overlayIf(bannerURL != nil) {
            Group {
                if let url = bannerURL {
                    LazyImage(url: url) { state in
                        if let image = state.image {
                            image
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        } else {
                            Color.clear
                        }
                    }.allowsHitTesting(false)
                } else {
                    EmptyView()
                }
            }
        }.clipped())
        .cornerRadius(8)
        .task {
            await getMetadata()
            let response = await client.ping()
            ping = response?.time
        }
    }
                    
    func getMetadata() async {
        if isBase, LemmyKit.current.metadata != nil {
            metadata = LemmyKit.current.metadata
        } else {
            if let siteView = InstanceDetailsCache.shared.cache[host] {
                metadata = .init(siteView: siteView)
                return
            }
            
            guard let response = await client.site() else { return }
            InstanceDetailsCache.shared.cache[host] = response.site_view
            metadata = .init(siteView: response.site_view)
        }
    }
}

#if DEBUG
struct InstanceCardView_Previews: PreviewProvider {
    static var previews: some View {
        InstanceCardView(.init(id: 0,
                               domain: "https://lemmy.world",
                               published: Date.now.asString))
        .padding(.layer2)
    }
}
#endif

//TODO: use in Feed as well
extension View {
    func textReadabilityIf(_ condition: Bool) -> some View {
        self
            .padding(.vertical, condition ? .layer1 : 0)
            .padding(.horizontal, condition ? .layer2 : 0)
            .backgroundIf(condition) {
                Color.background.opacity(0.75)
                    .cornerRadius(6)
            }
    }
}

fileprivate extension TimeInterval {
    var pingHealth: PingBars.Health {
        if self > 3 {
            return .bad
        } else if self > 1 {
            return .good
        } else {
            return .best
        }
    }
}

struct PingBars: View {
    var time: TimeInterval
    var isDisconnected: Bool = false
    
    
    var timeDisplay: String {
        "\(Int(time * 100))"
    }
    
    enum Health {
        case best
        case good
        case bad
        
        var color: Color {
            switch self {
            case .bad:
                return .red
            case .good:
                return .yellow
            default:
                return .green
            }
        }
    }
    
    var pingHealth: Health {
        guard !isDisconnected else {
            return .bad
        }
        return time.pingHealth
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            VStack {
                if isDisconnected {
                    Text("~")
                        .font(.headline.bold())
                } else {
                    Text(timeDisplay)
                        .font(.headline.bold())
                        .foregroundColor(.foreground) + Text(" ms")
                }
            }
            .padding(.trailing, .layer2)
            
            Rectangle()
                .frame(width: 4, height: 6)
                .foregroundColor(pingHealth.color)
            Rectangle()
                .frame(width: 4, height: 10)
                .foregroundColor(pingHealth.color)
            Rectangle()
                .frame(width: 4, height: 16)
                .foregroundColor(pingHealth.color)
        }
    }
}
