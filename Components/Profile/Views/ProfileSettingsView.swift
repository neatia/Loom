//
//  ProfileDetailsView.swift
//  Loom
//
//  Created by PEXAVC on 7/26/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import NukeUI
import FederationKit

#if os(macOS)
import AppKit
#endif

/*
 show_nsfw
 show_scores
 default_sort_type
 default_listing_type
 interface_language
 avatar
 banner
 display_name
 bio
 show_bot_accounts
 
 discussion_languages
 */

protocol StandardMotify: GranitePayload, Equatable {
    var showNSFW: Bool { get set }
    var showScores: Bool { get set }
    var showBotAccounts: Bool { get set }
    var sortType: FederatedSortType? { get set }
    var listingType: FederatedListingType? { get set }
}

struct LocalModifyMeta: StandardMotify {
    var showNSFW: Bool
    var showScores: Bool
    var showBotAccounts: Bool
    var sortType: FederatedSortType?
    var listingType: FederatedListingType?
    
    static func ==(lhs: LocalModifyMeta, rhs: LocalModifyMeta) -> Bool {
        lhs.showNSFW == rhs.showNSFW &&
        lhs.showScores == rhs.showScores &&
        lhs.showBotAccounts == rhs.showBotAccounts &&
        lhs.sortType == rhs.sortType &&
        lhs.listingType == rhs.listingType
    }
}

struct AccountModifyMeta: StandardMotify {
    var showNSFW: Bool
    var showScores: Bool
    var showBotAccounts: Bool
    var sortType: FederatedSortType?
    var listingType: FederatedListingType?
    var avatar: String?
    var banner: String?
    var displayName: String?
    var bio: String?
    var lastUpdated: String?
    
    static func fromLocal(_ user: UserInfo) -> AccountModifyMeta {
        .init(showNSFW: user.metadata.show_nsfw, showScores: user.metadata.show_scores, showBotAccounts: user.metadata.show_bot_accounts, sortType: user.metadata.default_sort_type, listingType: user.metadata.default_listing_type, avatar: user.person.avatar, banner: user.person.banner, displayName: user.person.display_name, bio: user.person.bio, lastUpdated: user.person.updated)
    }
    
    static func ==(lhs: AccountModifyMeta, rhs: AccountModifyMeta) -> Bool {
        lhs.showNSFW == rhs.showNSFW &&
        lhs.showScores == rhs.showScores &&
        lhs.showBotAccounts == rhs.showBotAccounts &&
        lhs.sortType == rhs.sortType &&
        lhs.listingType == rhs.listingType &&
        (lhs.avatar == rhs.avatar || (lhs.avatar?.isEmpty == true && rhs.avatar == nil)) &&
        (lhs.banner == rhs.banner || (lhs.banner?.isEmpty == true && rhs.banner == nil)) &&
        (lhs.displayName == rhs.displayName || (lhs.displayName?.isEmpty == true && rhs.displayName == nil)) &&
        (lhs.bio == rhs.bio || (lhs.bio?.isEmpty == true && rhs.bio == nil))
    }
}

struct ProfileSettingsView: View {
    @Environment(\.graniteEvent) var update
    @Environment(\.graniteRouter) var router
    @Environment(\.presentationMode) var presentationMode
    
    @Relay var account: AccountService
    @Relay var config: ConfigService
    @Relay var content: ContentService
    
    @State var showNSFW: Bool = false
    @State var showScores: Bool = true
    @State var showBotAccounts: Bool = true
    
    @State var sortType: FederatedSortType? = nil
    @State var listingType: FederatedListingType? = nil
    
    @State var imageDataAvatar: Data? = nil
    @State var imageDataBanner: Data? = nil
    
    @State var avatar: String = ""
    @State var avatarUserContent: UserContent? = nil
    @State var banner: String = ""
    @State var bannerUserContent: UserContent? = nil
    
    @State var displayName: String = ""
    @State var bio: String = ""
    
    @State var lastUpdated: String?
    
    var offline: Bool {
        forceOffline ? true : account.isLoggedIn == false
    }
    
    var currentMeta: AccountModifyMeta {
        .init(showNSFW: showNSFW, showScores: showScores, showBotAccounts: showBotAccounts, sortType: sortType, listingType: listingType, avatar: avatar, banner: banner, displayName: displayName, bio: bio, lastUpdated: lastUpdated)
    }
    
    var currentLocalMeta: LocalModifyMeta {
        .init(showNSFW: showNSFW, showScores: showScores, showBotAccounts: showBotAccounts, sortType: sortType, listingType: listingType)
    }
    
    var changesMade: Bool {
        currentMeta != model && model != nil
    }
    
    var localChangesMade: Bool {
        currentLocalMeta != localModel && localModel != nil
    }
    
    var model: AccountModifyMeta? {
        if let localUserView = account.state.meta?.resource.user {
            return .fromLocal(localUserView)
        } else {
            return nil
        }
    }
    
    @State var isUpdating: Bool = false
    
    @State var localModel: LocalModifyMeta?
    
    let showProfileSettings: Bool
    let isModal: Bool
    let forceOffline: Bool
    
    init(showProfileSettings: Bool = true,
         offline: Bool = false,
         isModal: Bool = false) {
        self.showProfileSettings = showProfileSettings
        self.forceOffline = offline
        self.isModal = isModal
        
        self.localModel = .init(showNSFW: config.state.showNSFW,
                                showScores: config.state.showScores,
                                showBotAccounts: config.state.showBotAccounts,
                                sortType: config.state.sortType,
                                listingType: config.state.listingType)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if offline == false {
                HStack(spacing: .layer4) {
                    VStack {
                        Spacer()
                        Text("TITLE_ACCOUNT")
                            .font(.title.bold())
                    }
                    
                    Spacer()
                    
                    
                    VStack {
                        Spacer()
                        if changesMade {
                            if isUpdating {
                                StandardProgressView()
                            } else {
                                Button {
                                    GraniteHaptic.light.invoke()
                                    config.center.update.send(currentMeta)
                                    account.center.update.send(currentMeta)
                                    isUpdating = true
                                } label: {
                                    Text("MISC_UPDATE")
                                        .foregroundColor(Device.isMacOS ? .white : .accentColor)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        } else {
                            Color.clear.onAppear {
                                isUpdating = false
                            }
                        }
                    }
                }
                .frame(height: 36)
                .padding(.bottom, .layer4)
                .padding(.horizontal, .layer4)
                
                Divider()
                    .padding(.bottom, .layer2)
            }
            
            if isModal {
                ScrollView(showsIndicators: false) {
                    settingOptions
                    
                    //TODO: delete account feature
//                    VStack(spacing: .layer3) {
//                        Spacer()
//                        Divider()
//
//                        HStack {
//                            Spacer()
//                            Button {
//                                GraniteHaptic.light.invoke()
//                            } label: {
//                                Text("AUTH_DELETE_ACCOUNT")
//                                    .font(Device.isMacOS ? .title3.bold() : .headline.bold())
//                                    .foregroundColor(Brand.Colors.red)
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                            Spacer()
//                        }
//                        .padding(.top, .layer2)
//                        .padding(.bottom, .layer4)
//                    }
                }
            } else {
                settingOptions
            }
            
            if showProfileSettings {
                Divider()
                
                HStack {
                    Spacer()
                    Button {
                        GraniteHaptic.light.invoke()
                        account
                            .center
                            .logout
                            .send()
                        presentationMode.wrappedValue.dismiss()
                        router.pop()
                    } label: {
                        Text("MISC_LOGOUT")
                            .font(Device.isMacOS ? .title3.bold() : .headline.bold())
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .padding(.vertical, .layer4)
            }
        }
        .background(Color.background)
        .onChange(of: currentLocalMeta) { status in
            guard offline else { return }
            updateLocalSettings()
        }
        .task {
            if offline == false,
               let model {
                content.preload()
                showNSFW = model.showNSFW
                showScores = model.showScores
                showBotAccounts = model.showBotAccounts
                sortType = model.sortType
                listingType = model.listingType
                avatar = model.avatar ?? ""
                banner = model.banner ?? ""
                avatarUserContent = content.state.userContent.values.first(where: { $0.contentURL == model.avatar })
                bannerUserContent = content.state.userContent.values.first(where: { $0.contentURL == model.banner })
                displayName = model.displayName ?? ""
                bio = model.bio ?? ""
                lastUpdated = model.lastUpdated
            } else {
                showNSFW = config.state.showNSFW
                showScores = config.state.showScores
                showBotAccounts = config.state.showBotAccounts
                sortType = config.state.sortType
                listingType = config.state.listingType
            }
        }
    }
    
    var settingOptions: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showProfileSettings && offline == false {
                
                HStack(spacing: .layer2) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("TITLE_AVATAR")
                                .font(.title3.bold())
                                .padding(.bottom, .layer2)
                            Spacer()
                        }
                        avatarView
                            .onChange(of: imageDataAvatar, perform: { data in
                                guard let data else { return }
                                
                                _ = Task.detached(priority: .userInitiated) { @MainActor in
                                    guard let content = await self.getUserContent(data) else {
                                        return
                                    }
                                    
                                    self.avatar = content.contentURL
                                    self.avatarUserContent = content
                                }
                            })
                    }
                    .frame(maxWidth: 75)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("TITLE_BANNER")
                                .font(.title3.bold())
                                .padding(.bottom, .layer2)
                            Spacer()
                        }
                        bannerView
                            .onChange(of: imageDataBanner, perform: { data in
                                guard let data else { return }
                                
                                _ = Task.detached(priority: .userInitiated) { @MainActor in
                                    guard let content = await self.getUserContent(data) else {
                                        return
                                    }
                                    
                                    self.banner = content.contentURL
                                    self.bannerUserContent = content
                                }
                            })
                    }
                }
                .padding(.bottom, .layer4)
                
                Text("PROFILE_BIO")
                    .font(.title3.bold())
                    .padding(.bottom, .layer2)
                
                StandardTextView(text: $bio)
                    .padding(.bottom, .layer4)
                
                Text("PROFILE_DISPLAY_NAME")
                    .font(.title3.bold())
                    .padding(.bottom, .layer2)
                
                TextField("", text: $displayName)
                    .textFieldStyle(.plain)
                    .frame(height: 60)
                    .padding(.horizontal, .layer4)
                    .font(.title3.bold())
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.secondaryBackground)
                    )
                    .padding(.bottom, .layer4)
            }
            
            HStack {
                Toggle(isOn: $showNSFW) {
                    Text("PROFILE_ADULT_CONTENT")
                        .font(.body)
                        .offset(x: 0, y: Device.isMacOS ? -1 : 0)
                }
                .padding(.bottom, .layer3)
                #if os(macOS)
                Spacer()
                #endif
            }
            
            HStack {
                Toggle(isOn: $showScores) {
                    Text("PROFILE_SHOW_SCORES")
                        .font(.body)
                        .offset(x: 0, y: Device.isMacOS ? -1 : 0)
                }
                .padding(.bottom, .layer3)
                #if os(macOS)
                Spacer()
                #endif
            }
            
            HStack {
                Toggle(isOn: $showBotAccounts) {
                    Text("PROFILE_SHOW_BOT_ACCOUNTS")
                        .font(.body)
                        .offset(x: 0, y: Device.isMacOS ? -1 : 0)
                }
                #if os(macOS)
                Spacer()
                #endif
            }
            
        
        }
        .padding(.layer4)
        
        
    }
}

extension ProfileSettingsView {
    
    var avatarView: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.secondaryBackground)
            
            
            if let url = URL(string: avatar) {
                LazyImage(url: url) { state in
                    if let image = state.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                            .overlay {
                                Color.background.opacity(0.6)
                            }
                    } else {
                        EmptyView()
                    }
                }
            }
            
            HStack(spacing: .layer2) {
                if let avatarUserContent {
                    Button {
                        GraniteHaptic.light.invoke()
                        
                        _ = Task.detached(priority: .userInitiated) { @MainActor in
                            let result = await Federation.deleteImage(avatarUserContent.media)
                            //TODO: check
                            self.avatarUserContent = nil
                            self.imageDataAvatar = nil
                            self.avatar = ""
                        }
                    } label : {
                        Image(systemName: "trash")
                            .font(.title3.bold())
                            .foregroundColor(.red)
                            .offset(x: 0, y: -1)
                    }.buttonStyle(PlainButtonStyle())
                } else {
                    Button {
                        GraniteHaptic.light.invoke()
                        importPicture(setAvatar: true, setBanner: false)
                    } label : {
                        Image(systemName: "plus.app")
                            .font(.title3.bold())
                            .foregroundColor(.foreground)
                            .offset(x: 0, y: -1)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .frame(width: 60, height: 60)
        .cornerRadius(30)
        .clipped()
    }
    
    var bannerView: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.secondaryBackground)
            
            if let url = URL(string: banner) {
                LazyImage(url: url) { state in
                    if let image = state.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                            .overlay {
                                Color.background.opacity(0.6)
                            }
                    } else {
                        EmptyView()
                    }
                }
            }
            
            
            HStack(spacing: .layer2) {
                if let bannerUserContent {
                    Button {
                        GraniteHaptic.light.invoke()
                        
                        _ = Task.detached(priority: .userInitiated) { @MainActor in
                            let result = await Federation.deleteImage(bannerUserContent.media)
                            
                            self.bannerUserContent = nil
                            self.imageDataBanner = nil
                            self.banner = ""
                        }
                    } label : {
                        Image(systemName: "trash")
                            .font(.title3.bold())
                            .foregroundColor(.red)
                            .offset(x: 0, y: -1)
                    }.buttonStyle(PlainButtonStyle())
                } else {
                    Button {
                        GraniteHaptic.light.invoke()
                        importPicture(setAvatar: false, setBanner: true)
                    } label : {
                        Image(systemName: "plus.app")
                            .font(.title3.bold())
                            .foregroundColor(.foreground)
                            .offset(x: 0, y: -1)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .frame(height: 60)
        .cornerRadius(8)
        .clipped()
    }
}

extension ProfileSettingsView {
    func getUserContent(_ data: Data) async -> UserContent? {
        let response = await Federation.uploadImage(data)
        
        guard let response else {
            return nil
        }
        
        return .init(media: response)
    }
}

extension ProfileSettingsView {
    func updateLocalSettings() {
        config._state.showNSFW.wrappedValue = currentMeta.showNSFW
        config._state.showScores.wrappedValue = currentMeta.showScores
        config._state.sortType.wrappedValue = currentMeta.sortType ?? config.state.sortType
        config._state.listingType.wrappedValue = currentMeta.listingType ?? config.state.listingType
        config._state.showBotAccounts.wrappedValue = currentMeta.showBotAccounts
        
        if offline {
            self.localModel = self.currentLocalMeta
        }
    }
}

//TODO: shared with Write.import, should make reusable
#if os(macOS)
import AppKit

extension ProfileSettingsView {
    func importPicture(setAvatar: Bool, setBanner: Bool) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowedContentTypes = [.image]
        if panel.runModal() == .OK {
            if let url = panel.url {
                
                if let data = try? Data(contentsOf: url),
                   let image = NSImage(data: data) {
                    if setAvatar {
                        self.imageDataAvatar = image.compress().pngData()
                    } else if setBanner {
                        self.imageDataBanner = image.compress().pngData()
                    }
                }
            }
        }
    }
}
#else
import PhotosUI

extension ProfileSettingsView {
    
    func importPicture(setAvatar: Bool, setBanner: Bool) {
        ModalService.shared.presentSheet {
            ImagePicker(imageData: setAvatar ? $imageDataAvatar : $imageDataBanner)
                .attach( {
                    ModalService.shared.dismissSheet()
                }, at: \.dismiss)
        }
    }
}
#endif
