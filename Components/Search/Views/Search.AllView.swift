//
//  Search.AllView.swift
//  Lemur
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
                                ForEach(model.comments) { cModel in
                                    CommentCardView(model: cModel,
                                                    isPreview: true)
//                                    .attach( { commentView in
//                                        showDrawer.perform(commentView)
//                                    }, at: \.showDrawer)
                                    .frame(minWidth: ContainerConfig.iPhoneScreenWidth * 0.9, maxWidth: 450)
                                    .frame(height: 240)
                                    
                                    if cModel.id != model.comments.last?.id {
                                        
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
                                ForEach(model.posts) { pModel in
                                    PostCardView(model: pModel, isPreview: true)
                                        .frame(minWidth: ContainerConfig.iPhoneScreenWidth * 0.9, maxWidth: 450)
                                        .frame(height: 200)
                                    
                                    if pModel.id != model.posts.last?.id {
                                        
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


