//
//  AccountModuleView.swift
//  Lemur
//
//  Created by PEXAVC on 7/24/23.
//

import Foundation
import SwiftUI
import Granite

struct AccountModuleView: View {
    enum Size {
        case normal
        case large
    }
    
    var model: AccountMeta
    var size: CGSize = .init(width: 126, height: 126)
    var styleSize: Size = .normal
    var showCustomLabel: Bool = false
    var isActive: Bool = false
    
    var iconSize: CGFloat {
        switch styleSize {
        case .large:
            return 36
        case .normal:
            return 24
        }
    }
    
    @State var isHovering: Bool = false
    
    var body: some View {
        AppBlurView(size: .init(width: 0, height: size.height),
                    tintColor: isActive ? (Brand.Colors.green.opacity(0.7)) : (.tertiaryBackground.opacity(0.45))) {
            
            ZStack {
                
                if isHovering {
                    RoundedRectangle(cornerRadius: 6)
                        .foregroundColor(.accentColor.opacity(0.9))
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("@\(model.username)")
                            .font(Fonts.live(styleSize == .large ? .subheadline : .caption2, .bold))
                            .padding(.horizontal, .layer2)
                            .padding(.vertical, .layer1)
                            .background(Color.background.opacity(0.9))
                            .frame(height: iconSize)
                            .cornerRadius(6)
                        
                        Spacer()
                    }
                    .padding(.bottom, .layer2)
//                    HStack {
//                        AppBlurView(size: .init(iconSize, iconSize),
//                                    padding: .init(.zero),
//                                    tintColor: Color.black.opacity(0.75)) {
//                            Text("/\(model.info.local_user_view.counts.totalScore)")
//                                .font(Fonts.live(styleSize == .large ? .subheadline : .caption2, .bold))
//                                .padding(.horizontal, .layer1)
//                        }
//                        .aspectRatio(1, contentMode: .fit)
//                        .frame(width: iconSize, height: iconSize)
//                        
//                        Spacer()
//                    }
//                    .padding(.bottom, .layer2)
                    
                    Text("\(String(model.info.local_user_view.counts.post_count)) POSTS_COUNT")
                        .lineLimit(styleSize == .large ? 5 : 3)
                        .font(Fonts.live(styleSize == .large ? .footnote : .caption, .regular))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, .layer1)
                    Text("\(String(model.info.local_user_view.counts.comment_count)) COMMENTS_COUNT")
                        .lineLimit(styleSize == .large ? 5 : 3)
                        .font(Fonts.live(styleSize == .large ? .footnote : .caption, .regular))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, .layer2)
                    
                    Spacer()
                    
                    HStack {
                        Text("\(model.hostDisplay)")
                            .font(Fonts.live(.caption2, .bold))
                        
                        Spacer()
                    }
                    .padding(.bottom, 2)
                    
//                    if let date = prompt.dateCreated {
//                        HStack {
//                            Text("\(date.asString)")
//                                .font(Fonts.live(.caption2, .bold))
//
//                            Spacer()
//
//                            if showCustomLabel && prompt.isSystemPrompt == false {
//                                Text("custom")
//                                    .font(Fonts.live(.footnote, .bold))
//                                    .padding(.vertical, 4)
//                                    .foregroundColor(Color.orange)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 6)
//                                            .strokeBorder(Color.orange,
//                                                          lineWidth: 2)
//                                            .padding(.horizontal, -6)
//                                    )
//                                    .padding(.horizontal, 6)
//                            }
//                        }
//                    }
                }
                .padding(.layer2)
            }
            .frame(width: size.width, height: size.height)
            .foregroundColor(.foreground)
        }
        .frame(width: size.width, height: size.height)
//        .onHover { isHovered in
//            DispatchQueue.main.async { //<-- Here
//                self.isHovering = isHovered
//                if self.isHovering {
//                    NSCursor.pointingHand.push()
//                } else {
//                    NSCursor.pop()
//                }
//            }
//        }
    }
}
