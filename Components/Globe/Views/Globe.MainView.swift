//
//  Globe.Accounts.swift
//  Loom
//
//  Created by PEXAVC on 8/4/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI

extension Globe {
    var mainView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: .layer4) {
                Button {
                    GraniteHaptic.light.invoke()
                    guard state.tab != .accounts else { return }
                    _state.tab.wrappedValue = .accounts
                } label: {
                    VStack {
                        Spacer()
                        Text("TITLE_ACCOUNTS")
                            .font(state.tab == .accounts ? .title.bold() : .title2.bold())
                            .opacity(state.tab == .accounts ? 1.0 : 0.6)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    GraniteHaptic.light.invoke()
                    guard state.tab != .explorer else { return }
                    _state.tab.wrappedValue = .explorer
                } label: {
                    VStack {
                        Spacer()
                        Text("MISC_EXPLORE")
                            .font(state.tab == .explorer ? .title.bold() : .title2.bold())
                            .opacity(state.tab == .explorer ? 1.0 : 0.6)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .frame(height: 36)
            .padding(.top, ContainerConfig.generalViewTopPadding)
            .padding(.leading, .layer4)
            .padding(.trailing, .layer4)
            .padding(.bottom, .layer4)
            
            Divider()
            
            switch state.tab {
            case .accounts:
                accountsView
            case .explorer:
                if isTabSelected == true {
                    GlobeExplorerView()
                        .graniteEvent(config.center.restart)
                } else {
                    EmptyView()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
