//
//  Feed.SetInstanceURL.swift
//  Loom
//
//  Created by PEXAVC on 8/17/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI

extension Feed {
    func setInstanceURL() {
        var value: String = ""
        var bindingString = Binding<String>.init(get: {
            return value
        }, set: { newValue in
            value = newValue
        })
        
        modal.presentSheet {
            //TODO: localize
            GraniteStandardModalView(title: "Set Instance URL", maxHeight: 210) {
                VStack(spacing: 0) {
                    TextField("MISC_URL", text: bindingString)
                        .textFieldStyle(.plain)
                        .correctionDisabled()
                        .frame(height: 40)
                        .padding(.horizontal, .layer4)
                        .font(.title3.bold())
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color.alternateBackground.opacity(0.3))
                        )
                    
                    HStack(spacing: .layer2) {
                        Spacer()
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            modal.dismissSheet()
                        } label: {
                            Text("MISC_CANCEL")
                                .font(.headline)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, .layer2)
                        
                        Button {
                            GraniteHaptic.light.invoke()
                            
                            config.center.restart.send(ConfigService.Restart.Meta(host: value))
                            
                            modal.dismissSheet()
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
    }
}
