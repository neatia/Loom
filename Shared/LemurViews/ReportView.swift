//
//  LoginView.swift
//  Lemur
//
//  Created by PEXAVC on 7/19/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import LemmyKit

struct ReportView: View {
    @GraniteAction<Void> var cancel
    @GraniteAction<Void> var add
    
    enum Kind {
        case post(PostView)
        case comment(CommentView)
    }
    
    struct Submit: GraniteModel {
        var reason: String
        var model: PostView
    }
    
    var kind: Kind
    
    @State var reason: String = ""
    
    @Relay var account: AccountService
    
    var title: LocalizedStringKey {
        switch kind {
        case .post:
            return "MISC_POST"
        case .comment:
            return "MISC_COMMENT"
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                #if os(iOS)
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(Color.background)
                    .edgesIgnoringSafeArea(.all)
                #endif
                
                reportForm
            }
            .frame(maxHeight: 400)
        }
        .frame(width: Device.isMacOS ? 300 : nil, height: Device.isMacOS ? 400 : nil)
    }
}

extension ReportView {
    var reportForm: some View {
        VStack(spacing: 0) {
            HStack(spacing: .layer4) {
                VStack {
                    Spacer()
                    
                    Text("MISC_REPORT")
                        .font(.title.bold()) + Text(title)
                        .font(.title.bold())
                }
                
                Spacer()
            }
            .frame(height: 36)
            .padding(.bottom, .layer4)
            
            Divider()
                .padding(.bottom, .layer4)
            
            if #available(macOS 13.0, iOS 16.0, *) {
                TextEditor(text: $reason)
                    .textFieldStyle(.plain)
                    .frame(height: 160)
                    .font(.title3.bold())
                    .scrollContentBackground(.hidden)
                    .padding(.layer3)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.tertiaryBackground)
                    )
                    .padding(.bottom, .layer3)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            StandardToolbarView()
                        }
                    }
            } else {
                TextEditor(text: $reason)
                    .textFieldStyle(.plain)
                    .font(.title3.bold())
                    .frame(height: 160)
                    .padding(.layer3)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.tertiaryBackground)
                    )
                    .padding(.bottom, .layer3)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            StandardToolbarView()
                        }
                    }
            }
            
            HStack(spacing: .layer2) {
                Spacer()
                
                Button {
                    GraniteHaptic.light.invoke()
                    switch kind {
                    case .post(let postView):
                        account
                            .center
                            .interact
                            .send(AccountService
                                .Interact
                                .Meta(intent: .reportPost(postView)))
                    case .comment(let commentView):
                        account
                            .center
                            .interact
                            .send(AccountService
                                .Interact
                                .Meta(intent: .reportComment(commentView)))
                    }
                } label: {
                    Text("MISC_SUBMIT")
                        .font(.headline)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, .layer2)
                
                Spacer()
            }
            
            Spacer()
        }
        .padding(.layer5)
    }
}
