//
//  LogoView.swift
//  Loom
//
//  Created by PEXAVC on 8/17/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

struct LogoView: View {
    @GraniteAction<Void> var write
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                
                Spacer()
                
                Button {
                    GraniteHaptic.light.invoke()
                    write.perform()
                } label: {
                    Image("logo_small")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .shadow(color: Color.background.opacity(0.75),
                                radius: 6)
                }.buttonStyle(.plain)
            }
        }.padding(.layer4)
    }
}
