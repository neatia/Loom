import Granite
import SwiftUI
import GraniteUI

extension Bookmark: View {
    
    @MainActor
    public var view: some View {
        VStack(spacing: 0) {
            if showHeader {
                HStack(spacing: .layer4) {
                    VStack {
                        Spacer()
                        Text("TITLE_BOOKMARKS")
                            .font(.title.bold())
                    }
                    
                    Spacer()
                }
                .frame(height: 36)
                .padding(.top, ContainerConfig.generalViewTopPadding)
                .padding(.leading, .layer4)
                .padding(.trailing, .layer4)
            }
            
            
            HStack(spacing: showHeader == false ? .layer3 : .layer4) {
                Button {
                    GraniteHaptic.light.invoke()
                    _state.kind.wrappedValue = .posts
                } label: {
                    VStack {
                        Spacer()
                        Text("TITLE_POSTS")
                            .font(postsFont)
                            .opacity(postsHeaderOpacity)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    GraniteHaptic.light.invoke()
                    _state.kind.wrappedValue = .comments
                } label: {
                    VStack {
                        Spacer()
                        Text("TITLE_COMMENTS")
                            .font(commentsFont)
                            .opacity(commentsHeaderOpacity)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .frame(height: 36)
            .padding(.bottom, showHeader == false ? .layer3 : .layer4)
            .padding(.leading, showHeader == false ? .layer3 :  .layer4)
            .padding(.trailing, showHeader == false ? .layer3 : .layer4)
            
            Divider()
            
            switch state.kind {
            case .posts:
                let postViewDomains: [String] = Array(service.state.posts.keys)
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(postViewDomains, id: \.self) { host in
                            if postViewDomains.count > 1 {
                                if host != postViewDomains.first {
                                    Divider()
                                }
                                
                                Section(header:
                                    headerView(for: host)
                                ) {
                                    postViews(for: host, indent: true)
                                }
                            } else {
                                postViews(for: host)
                            }
                        }
                    }.padding(.top, 1)
                }
            case .comments:
                let commentViewDomains: [String] = Array(service.state.comments.keys)
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(commentViewDomains, id: \.self) { host in
                            if commentViewDomains.count > 1 {
                                if host != commentViewDomains.first {
                                    Divider()
                                }
                                
                                Section(header:
                                    headerView(for: host)
                                ) {
                                    commentViews(for: host, indent: true)
                                }
                            } else {
                                commentViews(for: host)
                            }
                        }
                    }.padding(.top, 1)
                }
                .background(Color.alternateBackground)
            }
        }
        .addGraniteSheet(modal.sheetManager, background: Color.clear)
    }
    
    func headerView(for host: String) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(host)
                    .font(.title3.bold())
                    .foregroundColor(.foreground)
                    .padding(.horizontal, .layer3)
                
                Spacer()
                
            }
            
            Divider().padding(.vertical, .layer4)
        }
        .padding(.top, .layer5)
    }
    
    func postViews(for host: String, indent: Bool = false) -> some View {
        VStack {
            let postViews = postViews(host: host)
            ForEach(postViews) { postView in
                PostCardView(model: postView,
                             style: .style2,
                             viewingContext: showHeader ? .bookmark(host) : .bookmarkExpanded(host),
                             linkPreviewType: .largeNoMetadata)
                    .attach({ postView in
                        GraniteHaptic.light.invoke()
                        modal.presentSheet {
                            PostContentView(postView: postView)
                                .frame(width: Device.isMacOS ? 600 : nil, height: Device.isMacOS ? 500 : nil)
                        }
                    }, at: \.showContent)
                
                if postView.id != postViews.last?.id {
                    Divider()
                        .padding(.leading, indent ? .layer4 : nil)
                }
            }
        }
    }
    
    func commentViews(for host: String, indent: Bool = false) -> some View {
        VStack {
            let commentViews = commentViews(host: host)
            ForEach(commentViews) { commentView in
                CommentCardView(model: commentView,
                                postView: postForComment(commentView, host: host),
                                shouldLinkToPost: true,
                                viewingContext: .bookmark(host))
                
                if commentView.id != commentViews.last?.id {
                    Divider()
                        .padding(.leading, indent ? .layer4 : nil)
                }
            }
        }
    }
}
