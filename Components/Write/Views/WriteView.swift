//
//  WriteView.swift
//  Loom (iOS)
//
//  Created by PEXAVC on 7/21/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI
import MarkdownView

struct WriteView: View {
    var kind: Write.Kind
    
    @Binding var title: String
    @Binding var content: String
    
    var additionalPadding: CGFloat = 0
    
    #if os(macOS)
    @State var isVisible: Bool = true
    #else
    @State var isVisible: Bool = false
    #endif
    
    @State var id: UUID = .init()
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack {
            switch kind {
            case .compact:
                verticalContent
            case .full:
                horizontalContent
            case .replyPost,
                    .replyComment,
                    .editReplyPost,
                    .editReplyComment:
                if Device.isExpandedLayout {
                    horizontalContent
                } else {
                    //This is buggy in sheets
                    //the keyboard toolbar requires another NavigationView
                    //to propagate changes.
                    verticalContent
                }
            }
        }
        .onAppear {
            id = .init()
        }
    }
}

extension WriteView {
    var horizontalContent: some View {
        VStack(spacing: 0) {
            
            switch kind {
            case .replyComment,
                    .replyPost,
                    .editReplyPost,
                    .editReplyComment:
                EmptyView()
            default:
                TextField("MISC_TITLE", text: $title)
                    .textFieldStyle(.plain)
                    .frame(height: 30)
                    .font(.title3.bold())
                    .padding(.horizontal, .layer3)
                
                Divider()
                    .padding(.top, .layer2)
            }
            
            HStack(spacing: 0) {
                if #available(macOS 13.0, iOS 16.0, *) {
                    TextEditor(text: $content)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                        .foregroundColor(.foreground)
                        .background(.clear)
                        .font(.title3.bold())
                        .scrollContentBackground(Visibility.hidden)
                        .padding(.layer3)
                        .frame(maxWidth: .infinity)
                        .overlayIf(content.isEmpty && isFocused == false) {
                            placeholderView
                        }
                } else {
                    TextEditor(text: $content)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                        .foregroundColor(.foreground)
                        .background(.clear)
                        .font(.title3.bold())
                        .padding(.layer3)
                        .frame(maxWidth: .infinity)
                        .overlayIf(content.isEmpty && isFocused == false) {
                            placeholderView
                        }
                }
                
                Divider()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        MarkdownView(text: $content)
                            .markdownViewRole(.editor)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.layer3)
            }
        }
    }
    var verticalContent: some View {
        VStack(spacing: 0) {
            switch kind {
            case .replyComment,
                    .replyPost,
                    .editReplyPost,
                    .editReplyComment:
                EmptyView()
            default:
                TextField("MISC_TITLE", text: $title)
                    .textFieldStyle(.plain)
                    .frame(height: 30)
                    .font(.title3.bold())
                    .padding(.horizontal, .layer4 + additionalPadding)
                
                Divider()
                    .padding(.top, .layer2)
            }
            
            ZStack {
                
#if os(iOS)
                TextToolView(text: $content,
                             visibility: $isVisible)
                .attach({ state in
                    self.isFocused = state
                }, at: \.isFocused)
                .padding(.horizontal, .layer3)
                .padding(.top, .layer2)
                .overlayIf(content.isEmpty && isFocused == false) {
                    placeholderView
                }
#else
                
                if #available(macOS 13.0, iOS 16.0, *) {
                    TextEditor(text: $content)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                        .foregroundColor(.foreground)
                        .background(.clear)
                        .font(.title3.bold())
                        .scrollContentBackground(Visibility.hidden)
                        .padding(.horizontal, .layer3 + additionalPadding)
                        .padding(.top, .layer2)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                KeyboardToolbarSView(isVisible: $isVisible)
                            }
                        }
                        .overlayIf(content.isEmpty && isFocused == false) {
                            placeholderView
                        }
                        .id(id)
                } else {
                    NavigationView {
                        ZStack {
                            Color.background
                            
                            TextEditor(text: $content)
                                .textFieldStyle(.plain)
                                .focused($isFocused)
                                .foregroundColor(.foreground)
                                .background(.clear)
                                .font(.title3.bold())
                                .padding(.horizontal, .layer3 + additionalPadding)
                                .padding(.top, .layer2)
                                .id(id)
                                .toolbar {
                                    
                                    ToolbarItemGroup(placement: .keyboard) {
                                        KeyboardToolbarSView(isVisible: $isVisible)
                                    }
                                }
                                .frame(maxHeight: .infinity)
                                .hideNavBar()
                            
                        }
                        .overlayIf(content.isEmpty && isFocused == false && !isVisible) {
                            placeholderView
                        }
                    }
                    .inlineNavTitle()
                }
#endif
                if isVisible {
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            MarkdownView(text: $content)
                                .markdownViewRole(.editor)
                                .id(isVisible)
                                .padding(.vertical, .layer3)
                                .padding(.top, .layer2)//nitpick to align overlay with divider
                                .padding(.horizontal, .layer2)
                        }
                    }
                    .padding(.horizontal, .layer3)
                    .background(Color.background.opacity(0.9))
                }
            }
        }
    }
    
    var placeholderView: some View {
        VStack(alignment: .leading) {
            HStack {
                //TODO: localize
                Text("Write something...")
                    .font(.title3.bold())
                    .foregroundColor(.foreground.opacity(0.3))
                Spacer()
            }
            .padding(.horizontal, .layer4)
            .padding(.vertical, Device.isExpandedLayout ? .layer3 : .layer2)
            .padding(.top, .layer2)
            Spacer()
        }.allowsHitTesting(false)
    }
}

extension View {
    func hideNavBar() -> some View {
        #if os(iOS)
        self.navigationBarHidden(true)
        #else
        return self
        #endif
    }
    
    func inlineNavTitle() -> some View {
        #if os(iOS)
        return navigationBarTitleDisplayMode(.inline)
        #else
        return self
        #endif
    }
}

//TODO: Decide on necessity
struct KeyboardToolbarSView: View {
    @Binding var isVisible: Bool
    
    var body: some View {
        Group {
            Button {
                GraniteHaptic.light.invoke()
                
                UIApplication.hideKeyboard()
            } label : {
                if #available(macOS 13.0, iOS 16.0, *) {
                    Image(systemName: "keyboard.chevron.compact.down.fill")
                        .font(.headline)
                } else {
                    Image(systemName: "chevron.down")
                        .font(.headline)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Button {
                GraniteHaptic.light.invoke()
                isVisible.toggle()
            } label : {
                if !isVisible {
//                    Image(systemName: "arrow.up.and.down.square.fill")
//                        .font(.headline)
                    Image(systemName: "eye")
                        .font(.headline)
                    
                } else {
                    Image(systemName: "eye.slash")
                        .font(.headline)
//                    Image(systemName: "minus.square.fill")
//                        .font(.headline)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

