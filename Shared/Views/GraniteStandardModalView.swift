//
//  GraniteStandardView.swift
//  Loom
//
//  Created by PEXAVC on 7/22/23.
//

import Foundation
import GraniteUI
import Granite
import SwiftUI

//TODO: eventually convert all modals to this
struct GraniteStandardModalView<Header: View, Content: View>: View {
    var title: LocalizedStringKey?
    var maxHeight: CGFloat
    var fullWidth: Bool
    var showBG: Bool
    var alternateBG: Bool
    var drawerMode: Bool
    @Binding var shouldShowDrawer: Bool
    var canCloseDrawer: Bool
    var header: (() -> Header)
    var content: (() -> Content)
    
    //TODO: revise prop names and consider style struct
    init(title: LocalizedStringKey? = nil,
         maxHeight: CGFloat = Device.isMacOS ? 400 : 600,
         showBG: Bool = false,
         alternateBG: Bool = false,
         fullWidth: Bool = false,
         drawerMode: Bool = false,
         shouldShowDrawer: Binding<Bool>? = nil,
         @ViewBuilder header: @escaping (() -> Header) = { EmptyView() },
         @ViewBuilder content: @escaping (() -> Content)) {
        self.title = title
        self.maxHeight = maxHeight
        self.showBG = showBG
        self.alternateBG = alternateBG
        self.drawerMode = drawerMode
        self.fullWidth = fullWidth
        self.header = header
        self.content = content
        self._shouldShowDrawer = shouldShowDrawer ?? .constant(false)
        self.canCloseDrawer = drawerMode && shouldShowDrawer != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if Device.isMacOS == false && !drawerMode {
                Spacer()
            }
            
            ZStack {
                
                if Device.isMacOS == false || showBG {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(alternateBG ? .alternateBackground : Color.background)
                        .cornerRadius(16)
                        .edgesIgnoringSafeArea(.all)
                        .shadow(color: Brand.Colors.black.opacity(0.5), radius: 8)
                }
                
                VStack(spacing: 0) {
                    HStack(spacing: .layer4) {
                        VStack {
                            Spacer()
                            
                            if let title {
                                Text(title)
                                    .font(.title.bold())
                            } else {
                                header()
                            }
                        }
                        
                        if title != nil {
                            Spacer()
                        }
                        
                        if canCloseDrawer {
                            
                            Button {
                                GraniteHaptic.light.invoke()
                                shouldShowDrawer = false
                            } label: {
                                Image(systemName: "chevron.down")
                                    .font(.title3)
                                    .foregroundColor(.foreground)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(height: 36)
                    .padding(.bottom, Device.isMacOS ? .layer4 : .layer5)
                    .padding(.horizontal, Device.isMacOS ? .layer4 : .layer5)
                    
                    Divider()
                        .padding(.bottom, .layer4)
                    
                    content()
                        .padding(.horizontal, Device.isMacOS ? .layer4 : .layer5)
                        .padding(.top, Device.isMacOS ? nil : .layer4)
                        .padding(.bottom, Device.isMacOS ? nil : .layer5)
                    
                    Spacer()
                }
            }
            .frame(maxHeight: maxHeight)
            
        }
        .frame(width: Device.isMacOS && !fullWidth ? 300 : nil)
        .padding(.top, drawerMode || Device.isMacOS ? 0 : .layer5)
        .offset(x: 0, y: drawerMode ? .layer5 : 0)
    }
}