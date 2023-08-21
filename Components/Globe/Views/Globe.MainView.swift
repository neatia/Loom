//
//  Globe.Accounts.swift
//  Loom
//
//  Created by PEXAVC on 8/4/23.
//

import Foundation
import Granite
import GraniteUI
import SwiftUI

extension Globe {
    var mainView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: .layer4) {
                VStack {
                    Spacer()
                    Text("MISC_EXPLORE")
                        .font(.title.bold())
                }
                
                Spacer()
            }
            .frame(height: 36)
            .padding(.top, ContainerConfig.generalViewTopPadding)
            .padding(.leading, .layer4)
            .padding(.trailing, .layer4)
            .padding(.bottom, .layer4)
            
            Divider()
            
            if isTabSelected == true {
                GlobeExplorerView()
                    .graniteEvent(config.center.restart)
            } else {
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
    }
}
