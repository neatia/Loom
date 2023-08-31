//
//  ProfilePickerView.swift
//  Loom
//
//  Created by PEXAVC on 7/29/23.
//

import Foundation

import SwiftUI
import Granite
import GraniteUI

struct ProfilePickerView: View {
    @GraniteAction<Void> var refresh
    
    enum Kind: String, GraniteModel {
        case overview
        case mentions
        case replies
    }
    
    @Binding var kind: Kind
    var isMe: Bool
    
    func opacityFor(_ kind: Kind) -> CGFloat {
        return self.kind == kind ? 1.0 : 0.6
    }
    
    func fontFor(_ kind: Kind) -> Font {
        return self.kind == kind ? .title2.bold() : .title3.bold()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: .layer4) {
                
                Button {
                    GraniteHaptic.light.invoke()
                    refresh.perform()
                    kind = .overview
                } label: {
                    VStack {
                        Spacer()
                        Text("TITLE_OVERVIEW")
                            .font(fontFor(.overview))
                            .opacity(opacityFor(.overview))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                if isMe {
                    Button {
                        GraniteHaptic.light.invoke()
                        refresh.perform()
                        kind = .mentions
                    } label: {
                        VStack {
                            Spacer()
                            Text("TITLE_MENTIONS")
                                .font(fontFor(.mentions))
                                .opacity(opacityFor(.mentions))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        GraniteHaptic.light.invoke()
                        refresh.perform()
                        kind = .replies
                    } label: {
                        VStack {
                            Spacer()
                            Text("TITLE_REPLIES")
                                .font(fontFor(.replies))
                                .opacity(opacityFor(.replies))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
            .frame(height: 40)
            .padding(.bottom, .layer4)
            .padding(.leading, .layer4)
            .padding(.trailing, .layer4)
            .foregroundColor(.foreground)
            
//                    if kind != .overview {
//                        Divider()
//                    }
//
            Divider()
        }
    }
}
