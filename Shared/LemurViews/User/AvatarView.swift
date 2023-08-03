//
//  AvatarView.swift
//  Lemur
//
//  Created by PEXAVC on 7/13/23.
//

import Foundation
import SwiftUI
import LemmyKit
import NukeUI
import Granite

struct AvatarView: View {
    static var containerPadding: CGFloat = 5
    
    enum Size {
        case large
        case medium
        case small
        case mini
        
        var frame: CGFloat {
            switch self {
            case .large:
                return 64
            case .medium:
                return 48
            case .small:
                return 40
            case .mini:
                return 32
            }
        }
        
        var avatarSize: Font {
            switch self {
            case .large:
                return .title
            case .medium:
                return .title2
            case .small:
                return .title3
            case .mini:
                return Device.isMacOS ? .headline : .footnote
            }
        }
    }
    
    var avatarSize: Font {
        if isCommunity {
            if size == .small {
                return .footnote
            } else if size == .mini {
                return .caption2
            } else {
                return size.avatarSize.smaller
            }
        } else {
            return size.avatarSize
        }
    }
    
    let avatarURL: URL?
    let size: Size
    let isCommunity: Bool
    let person: Person?
    
    init(_ url: URL?, size: Size = .small, isCommunity: Bool = false) {
        self.avatarURL = url
        self.size = size
        self.isCommunity = isCommunity
        self.person = nil
    }
    
    init(_ person: Person?, size: Size = .small) {
        self.avatarURL = person?.avatarURL
        self.size = size
        self.isCommunity = false
        self.person = person
    }
    
    init(_ model: PostView, size: Size = .small) {
        self.avatarURL = model.avatarURL
        self.size = size
        self.isCommunity = false
        self.person = model.creator
    }
    
    init(_ model: CommentView, size: Size = .small) {
        self.avatarURL = model.avatarURL
        self.size = size
        self.isCommunity = false
        self.person = model.creator
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.secondaryBackground)
            
            if let avatarURL = self.avatarURL {
                
                LazyImage(url: avatarURL) { state in
                    if let image = state.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "person\(isCommunity ? ".3" : "")")
                            .font(avatarSize)
                            .foregroundColor(.foreground)
                            .offset(x: 0, y: -1)
                    }
                }
            } else {
                Image(systemName: "person\(isCommunity ? ".3" : "")")
                    .font(avatarSize)
                    .foregroundColor(.foreground)
                    .offset(x: 0, y: -1)
            }
        }
        .frame(width: size.frame, height: size.frame)
        .cornerRadius(size.frame / 2)
        .clipped()
        .routeIf(person != nil, style: .init(size: .init(width: 600, height: 500), styleMask: .resizable)) {
            Profile(person)
        }
    }
}
