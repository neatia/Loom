//
//  LoomsPickerView.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/27/23.
//

import Foundation
import LemmyKit
import SwiftUI
import Granite
import GraniteUI

struct LoomsPickerView: View {
    
    var meta: AccountMeta?
    
    var modal: Bool = true
    var verticalPadding: CGFloat = .layer5
    
    var communities: Pager<CommunityView> = .init(emptyText: "EMPTY_STATE_NO_COMMUNITIES", isStatic: true)
    
    @State var page: SearchType = .users
    
    func opacityFor(_ page: SearchType) -> CGFloat {
        return self.page == page ? 1.0 : 0.6
    }
    
    func fontFor(_ page: SearchType) -> Font {
        return self.page == page ? .title2.bold() : .title3.bold()
    }
    
    var body: some View {
        VStack {
            if modal {
                Spacer()
            }
            
            ZStack {
#if os(iOS)
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(Color.background)
                    .edgesIgnoringSafeArea(.all)
#endif
            }
            .frame(maxHeight: modal ? 400 : nil)
        }
        .padding(.top, modal ? 0 : verticalPadding)
        .padding(.bottom, modal ? 0 : verticalPadding)
    }
}

extension LoomsPickerView {
    var selectorView: some View {
        
        HStack(spacing: .layer4) {
            
            
            Button {
                GraniteHaptic.light.invoke()
            } label: {
                VStack {
                    Spacer()
                    Text("LISTING_TYPE_SUBSCRIBED")
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button {
                GraniteHaptic.light.invoke()
            } label: {
                VStack {
                    Spacer()
                    Text("LISTING_TYPE_LOCAL")
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button {
                GraniteHaptic.light.invoke()
            } label: {
                VStack {
                    Spacer()
                    Text("LISTING_TYPE_ALL")
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button {
                GraniteHaptic.light.invoke()
            } label: {
                VStack {
                    Spacer()
                    Image(systemName: "arrow.counterclockwise")
                        .font(.subheadline.bold())
                        .padding(.bottom, .layer1)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .frame(height: 36)
        .padding(.bottom, .layer4)
        .padding(.leading, .layer4)
        .padding(.trailing, .layer4)
        .foregroundColor(.foreground)
    }
}
