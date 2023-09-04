//
//  SetInstanceView.swift
//  Loom
//
//  Created by PEXAVC on 9/3/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

struct SetInstanceView: View {
    @GraniteAction<String> var commit
    
    @State var value: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: .layer4) {
                TextField("MISC_URL", text: $value)
                    .textFieldStyle(.plain)
                    .correctionDisabled()
                    .frame(height: 60)
                    .padding(.horizontal, .layer4)
                    .font(.title3.bold())
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.alternateBackground.opacity(0.3))
                    )
                
                Button {
                    GraniteHaptic.light.invoke()
                    let contents = Clipboard.contents ?? value
                    
                    if URL(string: contents) != nil {
                        self.value = contents
                    } else {
                        ModalService
                            .shared
                            .presentModal(
                                GraniteToastView(
                                    StandardErrorMeta(title: "MISC_ERROR",
                                                      //TODO: localize
                                                      message: "Not a valid URL",
                                                      event: .error)))
                    }
                } label: {
                    Image(systemName: "doc.on.clipboard.fill")
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: .layer2) {
                Spacer()
                
                Button {
                    GraniteHaptic.light.invoke()
                    ModalService.shared.dismissSheet()
                } label: {
                    Text("MISC_CANCEL")
                        .font(.headline)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, .layer2)
                
                Button {
                    GraniteHaptic.light.invoke()
                    commit.perform(value)
                } label: {
                    Text("MISC_DONE")
                        .font(.headline)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, .layer4)
        }
    }
}
