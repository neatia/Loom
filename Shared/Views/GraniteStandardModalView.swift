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
    var maxHeight: CGFloat?
    var fullWidth: Bool
    var fullWidthContent: Bool
    var showBG: Bool
    var alternateBG: Bool
    var drawerMode: Bool
    //unecessary option
    var customHeaderView: Bool
    @Binding var shouldShowDrawer: Bool
    var canCloseDrawer: Bool
    var header: (() -> Header)
    var content: (() -> Content)
    
    //TODO: revise prop names and consider style struct
    init(title: LocalizedStringKey? = nil,
         maxHeight: CGFloat? = Device.isMacOS ? 400 : 600,
         showBG: Bool = false,
         alternateBG: Bool = false,
         fullWidth: Bool = false,
         fullWidthContent: Bool = false,
         drawerMode: Bool = false,
         customHeaderView: Bool = false,
         shouldShowDrawer: Binding<Bool>? = nil,
         @ViewBuilder header: @escaping (() -> Header) = { EmptyView() },
         @ViewBuilder content: @escaping (() -> Content)) {
        self.title = title
        self.maxHeight = maxHeight
        self.showBG = showBG
        self.alternateBG = alternateBG
        self.drawerMode = drawerMode
        self.fullWidth = fullWidth
        self.fullWidthContent = fullWidthContent
        self.header = header
        self.content = content
        self.customHeaderView = customHeaderView
        self._shouldShowDrawer = shouldShowDrawer ?? .constant(false)
        self.canCloseDrawer = drawerMode && shouldShowDrawer != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            #if os(iOS)
            if Device.isiPad, !drawerMode {
                Spacer()
            }
            #endif
            
            ZStack {
                if Device.isMacOS == false || showBG {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(alternateBG ? .alternateBackground : (Device.isMacOS == false ? Color.secondaryBackground : Color.background))
                        .cornerRadius(16)
                        .edgesIgnoringSafeArea(.all)
                        .shadow(color: Brand.Colors.black.opacity(Device.isIPhone ? 0.0 : 0.5), radius: 8)
                }
                
                VStack(spacing: 0) {
                    HStack(spacing: .layer4) {
                        VStack {
                            if customHeaderView == false {
                                Spacer()
                            }
                            
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
                    .frame(height: customHeaderView ? nil : 36)
                    .padding(.bottom, .layer4)
                    .padding(.horizontal, .layer5)
                    //.padding(.top, Device.isExpandedLayout == false ? (Device.isIPhone ? .layer2 : .layer5) : 0)
                    .padding(.top, Device.isMacOS == false ? (Device.isIPhone ? .layer2 : .layer5) : 0)
                    
                    if !customHeaderView {
                        Divider()
                            .padding(.bottom, .layer4)
                    }
                    
                    content()
                        .padding(.horizontal, fullWidthContent ? 0 : .layer5)
                        .padding(.top, Device.isMacOS || Device.isiPad == false ? nil : .layer4)
                        .padding(.bottom, Device.isMacOS ? nil : .layer5)
                    
                    if Device.isiPad == false {
                        Spacer()
                    }
                }
            }
            .frame(maxHeight: maxHeight)
            
        }
        .frame(width: Device.isMacOS && !fullWidth ? ContainerConfig.iPhoneScreenWidth : nil)
        .padding(.top, drawerMode || Device.isMacOS ? .layer4 : .layer5)
        .offset(x: 0, y: drawerMode ? .layer5 : 0)
    }
}
