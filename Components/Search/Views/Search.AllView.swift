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
import LemmyKit

struct SearchAllView: View {
    @GraniteAction<CommentView> var showDrawer
    var model: SearchResponse
    
    @Relay var account: AccountService
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
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
                    .padding(.top, .layer4)
                    .padding(.bottom, .layer4)
                    .padding(.horizontal, .layer4)
                    
                    if model.communities.isEmpty {
                        HStack {
                            Text("EMPTY_STATE_NO_COMMUNITIES_FOUND")
                                .font(.title3.bold())
                        }
                        .padding(.horizontal, .layer4)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: .layer4) {
                                ForEach(model.communities) { model in
                                    CommunityCardView(model: model)
                                        .frame(maxWidth: ContainerConfig.iPhoneScreenWidth * 0.9)
                                        .route(window: .resizable(600, 500)) {
                                            Feed(model.community)
                                        }
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
                    .padding(.bottom, .layer4)
                    .padding(.horizontal, .layer4)
                    
                    if model.users.isEmpty {
                        HStack {
                            Text("EMPTY_STATE_NO_USERS_FOUND")
                                .font(.title3.bold())
                        }
                        .padding(.horizontal, .layer4)
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
                            Text("TITLE_COMMENTS")
                                .font(.title2.bold())
                        }
                        
                        Spacer()
                    }
                    .frame(height: 36)
                    .padding(.horizontal, .layer4)
                    .padding(.bottom, .layer4)
                    
                    if model.comments.isEmpty {
                        HStack {
                            Text("EMPTY_STATE_NO_COMMENTS_FOUND")
                                .font(.title3.bold())
                        }
                        .padding(.horizontal, .layer4)
                        .padding(.top, .layer4)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(model.comments) { commentView in
                                    CommentCardView()
                                        .contentContext(.init(commentModel: commentView,
                                                              viewingContext: .search))
                                        .frame(minWidth: ContainerConfig.iPhoneScreenWidth * 0.9, maxWidth: 450)
                                        .frame(height: 240)

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
                    .padding(.horizontal, .layer4)
                    .padding(.bottom, .layer4)
                    
                    if model.posts.isEmpty {
                        HStack {
                            Text("EMPTY_STATE_NO_POSTS_FOUND")
                                .font(.title3.bold())
                        }
                        .padding(.horizontal, .layer4)
                        .padding(.bottom, .layer4)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(model.posts) { postView in
                                    PostCardView()
                                        .frame(minWidth: ContainerConfig.iPhoneScreenWidth * 0.9, maxWidth: 450)
                                        .frame(height: 200)
                                        .contentContext(.init(postModel: postView,
                                                              feedStyle: .style1,
                                                              viewingContext: .search))
                                    
                                    if postView.id != model.posts.last?.id {
                                        
                                        Divider()
                                            .padding(.horizontal, .layer2)
                                    }
                                }
                                
                                Spacer().frame(width: .layer4)
                            }
                        }
                        .padding(.bottom, .layer4)
                    }
                }
                
            }
            
            Spacer()
        }
    }
}


