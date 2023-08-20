//
//  Globe.AccountsView.swift
//  Loom
//
//  Created by Ritesh Pakala on 8/18/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI

extension Globe {
    var accountsView: some View {
        VStack(spacing: 0) {
            WrapLayout(horizontalSpacing: .layer4, verticalSpacing: .layer4) {
                
                addView
                
                ForEach(Array(account.state.profiles)) { meta in
                    
                    Button {
                        GraniteHaptic.light.invoke()
                        
                        modal.presentModal(GraniteAlertView(message: .init("ALERT_SWITCH_ACCOUNT \("@\(meta.username)@\(meta.hostDisplay)")")) {
                            
                            GraniteAlertAction(title: "MISC_NO")
                            GraniteAlertAction(title: "MISC_YES") {
                                config.center.restart.send(ConfigService.Restart.Meta(accountMeta: meta))
                            }
                        })
                        
                    } label: {
                        AccountModuleView(model: meta,
                                          size: .init(width: state.accountModuleSize, height: state.accountModuleSize),
                                          isActive: account.state.meta?.id == meta.id)
                        .id(account.state.meta)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: state.accountModuleSize, height: state.accountModuleSize)
                }
            }
            .padding(.vertical, .layer4)
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}
