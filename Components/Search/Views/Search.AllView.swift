//
//  Search.AllView.swift
//  Loom
//
//  Created by PEXAVC on 7/25/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import FederationKit

struct SearchAllView: View {
    @Environment(\.graniteRouter) var router
    
    @GraniteAction<FederatedCommentResource> var showDrawer
    var model: FederatedSearchResult
    
    @Relay var account: AccountService
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Group {
                    HStack(spacing: .layer4) {
                        VStack {
                            Spacer()
                            Text("TITLE_COMMUNITIES")
                                .font(.title2.bold())
                        }
                        
                        Spacer()
                    }
                    .frame(height: 36)
                    .padding(.layer4)
                    
                    if model.communities.isEmpty {
                        HStack {
                            Text("EMPTY_STATE_NO_COMMUNITIES_FOUND")
                                .font(.subheadline)
                        }
                        .padding(.layer4)
                        .padding(.bottom, .layer2)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: .layer4) {
                                ForEach(model.communities) { model in
                                    CommunityCardView(model: model,
                                                      shouldRoute: true)
                                        .frame(maxWidth: ContainerConfig.iPhoneScreenWidth * 0.9)
                                }
                                
                                Spacer().frame(width: .layer4)
                            }
                            .padding(.leading, .layer4)
                        }
                    }
                }
                
                Divider()
                    .padding(.top, .layer4)
                
                Group {
                    HStack(spacing: .layer4) {
                        VStack {
                            Spacer()
                            Text("TITLE_USERS")
                                .font(.title2.bold())
                        }
                        
                        Spacer()
                    }
                    .frame(height: 36)
                    .padding(.layer4)
                    
                    if model.users.isEmpty {
                        HStack {
                            Text("EMPTY_STATE_NO_USERS_FOUND")
                                .font(.subheadline)
                        }
                        .padding(.layer4)
                        .padding(.bottom, .layer2)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: .layer4) {
                                ForEach(model.users) { user in
                                    UserCardView(model: user)
                                }
                                
                                Spacer().frame(width: .layer4)
                            }
                            .padding(.leading, .layer4)
                        }
                    }
                }
                
                Divider()
                    .padding(.top, .layer4)
                
                Group {
                    HStack(spacing: .layer4) {
                        VStack {
                            Spacer()
                            Text("TITLE_POSTS")
                                .font(.title2.bold())
                        }
                        
                        Spacer()
                    }
                    .frame(height: 36)
                    .padding(.layer4)
                    
                    if model.posts.isEmpty {
                        HStack {
                            Text("EMPTY_STATE_NO_POSTS_FOUND")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, .layer4)
                        .padding(.layer4)
                        //layer6 because last divider has no padding
                        .padding(.bottom, .layer6)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(model.posts) { postView in
                                    PostCardView()
                                        .frame(minWidth: ContainerConfig.iPhoneScreenWidth * 0.85, maxWidth: Device.isExpandedLayout ? 450 : ContainerConfig.iPhoneScreenWidth * 0.9)
                                        .frame(height: 220)
                                        .contentContext(.init(postModel: postView,
                                                              viewingContext: .search))
                                        .padding(.bottom, .layer4)
                                    
                                    if postView.id != model.posts.last?.id {
                                        
                                        Divider()
                                            .padding(.horizontal, .layer2)
                                    }
                                }
                                
                                Spacer().frame(width: .layer4)
                            }
                        }
                    }
                }
                
                Divider()
                
                Group {
                    HStack(spacing: .layer4) {
                        VStack {
                            Spacer()
                            Text("TITLE_COMMENTS")
                                .font(.title2.bold())
                        }
                        
                        Spacer()
                    }
                    .frame(height: 36)
                    .padding(.layer4)
                    
                    if model.comments.isEmpty {
                        HStack {
                            Text("EMPTY_STATE_NO_COMMENTS_FOUND")
                                .font(.subheadline)
                        }
                        .padding(.top, .layer4)
                        .padding(.bottom, .layer2)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(model.comments) { commentView in
                                    CommentCardView(context: .init(commentModel: commentView,
                                                                   viewingContext: .search).withStyle(.style2))
                                        .frame(minWidth: ContainerConfig.iPhoneScreenWidth * 0.8, maxWidth: Device.isExpandedLayout ? 450 : ContainerConfig.iPhoneScreenWidth * 0.9)
                                        .frame(height: 240)
                                        .padding(.bottom, .layer2)
                                    
                                    if commentView.id != model.comments.last?.id {
                                        
                                        Divider()
                                            .padding(.horizontal, .layer2)
                                    }
                                }
                                
                                
                                Spacer().frame(width: .layer4)
                            }
                        }
                    }
                }
            }
        }
    }
}


