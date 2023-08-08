//
//  DebugSettingsView.swift
//  Loom
//
//  Created by PEXAVC on 8/6/23.
//
import Granite
import GraniteUI
import Foundation
import SwiftUI

struct DebugSettingsView: View {
    @Environment(\.graniteEvent) var restart
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: .layer4) {
                VStack {
                    Spacer()
                    Text("⚠️")
                        .font(.title2.bold())
                }
                
                Spacer()
            }
            .frame(height: 36)
            .padding(.bottom, .layer4)
            .padding(.horizontal, .layer4)
            
            Divider()
            
            VStack(spacing: 0) {
                Button {
                    GraniteHaptic.light.invoke()
                    restart?.send(ConfigService.Restart.Meta(accountMeta: nil, host: "https://lemmy.world"))
                } label: {
                    Text("Reset to lemmy.world")
                        .font(.headline.bold())
                        .lineLimit(1)
                        .foregroundColor(Color.black)
                        .padding(.horizontal, .layer2)
                        .padding(.vertical, .layer1)
                        .background(RoundedRectangle(cornerRadius: .layer2)
                            .fill(Brand.Colors.yellow))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, .layer5)
            .padding(.horizontal, .layer4)
        }
        .padding(.top, .layer4)
        .background(Color.background)
    }
}
