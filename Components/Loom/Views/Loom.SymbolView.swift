//
//  Loom.SymbolView.swift
//  Loom
//
//  Created by PEXAVC on 8/13/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import FederationKit

struct LoomSymbolView: View {
    @Binding var displayKind: Loom.DisplayKind
    @Binding var intent: Loom.Intent
    var communityView: FederatedCommunityResource?
    
    var isViewingCommunity: Bool {
        communityView != nil
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button {
                    GraniteHaptic.light.invoke()
                    
                    
                    switch displayKind {
                    case .compact:
                        displayKind = .expanded
                        
                        if isViewingCommunity,
                           let communityView {
                            intent = .adding(communityView)
                        } else {
                            intent = .idle
                        }
                    case .expanded:
                        intent = .idle
                        displayKind = .compact
                    }
                } label: {
                    switch displayKind {
                    case .expanded:
                        ZStack {
                            Image("logo_small_bg")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .shadow(color: Color.background.opacity(0.75),
                                        radius: 6)
                            
                            Image(systemName: "xmark")
                                .font(.title)
                                .foregroundColor(Brand.Colors.black)
                        }
                    case .compact:
                        if isViewingCommunity {
                            ZStack {
                                Image("logo_small_bg")
                                    .resizable()
                                    .frame(width: 48, height: 48)
                                    .shadow(color: Color.background.opacity(0.75),
                                            radius: 6)
                                
                                Image(systemName: "plus")
                                    .font(.title)
                                    .foregroundColor(Brand.Colors.black)
                            }
                        } else {
                            
                            Image("logo_small")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .shadow(color: Color.background.opacity(0.75),
                                        radius: 6)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, .layer4)
        .padding(.bottom, displayKind == .expanded ? 0 : .layer4)
        .padding(.horizontal, .layer4)
    }
}
