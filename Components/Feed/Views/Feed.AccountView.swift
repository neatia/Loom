//
//  Feed.LoginView.swift
//  Loom
//
//  Created by PEXAVC on 7/19/23.
//

import Granite
import SwiftUI
import Foundation


struct AccountView: View {
    @Environment(\.graniteRouter) var router
    
    @GraniteAction<Void> var login
    @GraniteAction<Void> var notLoggedIn
    
    @Relay var account: AccountService
    
    var body: some View {
        VStack {
            if account.isLoggedIn,
               let meta = account.state.meta {
                Text("@"+meta.username)
                    .font(.headline.bold())
                    .overlay {
                        Rectangle()
                            .foregroundColor(Color.black.opacity(0.0001))
                            .routeIf(account.isLoggedIn,
                                     window: .resizable(600, 500)) {
                                Profile(account.state.meta?.person)
                            } with : { router }
                    }
                    .shiny()
            } else {
                Button {
                    login.perform()
                } label: {
                    Text("AUTH_LOGIN")
                        .font(.headline)
                        .foregroundColor(.foreground)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
