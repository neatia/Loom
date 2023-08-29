//
//  ListingSelectorView.swift
//  Loom
//
//  Created by PEXAVC on 8/28/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import LemmyKit

struct ListingSelectorView: View {
    @Environment(\.contentContext) var context
    @GraniteAction<Void> var fetch
    
    @Binding var listingType: ListingType
    
    var body: some View {
        Menu {
            Button {
                guard listingType != .all else { return }
                
                GraniteHaptic.light.invoke()
                listingType = .all
                
                fetch.perform()
            } label: {
                Text(ListingType.all.displayString)
                Image(systemName: "arrow.down.right.circle")
            }
            
            Button {
                guard listingType != .local else { return }
                
                GraniteHaptic.light.invoke()
                listingType = .local
                
                fetch.perform()
            } label: {
                Text(ListingType.local.displayString)
                Image(systemName: "arrow.down.right.circle")
            }
        } label: {
            Text(listingType.displayString)
#if os(iOS)
            Image(systemName: "chevron.up.chevron.down")
#endif
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .frame(maxWidth: Device.isMacOS ? 100 : nil)
    }
}
