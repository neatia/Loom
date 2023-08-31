//
//  HostSelectorView.swift
//  Loom
//
//  Created by PEXAVC on 8/28/23.
//

import Foundation
import SwiftUI
import Granite
import GraniteUI
import FederationKit

struct HostSelectorView: View {
    @Environment(\.contentContext) var context
    @GraniteAction<Void> var fetch
    
    @Binding var location: FederatedLocationType
    
    var model: FederatedResource? = nil
    
    var currentModel: FederatedResource? {
        model ?? (context.commentModel ?? context.postModel)
    }
    
    var viewableHosts: [String] {
        currentModel?.viewableHosts ?? []
    }
    
    var body: some View {
        let count = viewableHosts.count
        return Menu {
            ForEach(0..<count) { index in
                let isSource: Bool = currentModel?.location(for: viewableHosts[index]) == .source
                let isPeer: Bool = currentModel?.location(for: viewableHosts[index]).isPeer == true
                let imageName: String = isSource ? "globe.americas" : (isPeer ? "person.wave.2" : "house")
                Button {
                    GraniteHaptic.light.invoke()
                    
                    if isSource {
                        self.location = .source
                    } else if index > 0 {
                        if currentModel?.isPeerResource == true {
                            self.location = .peer(viewableHosts[index])
                        } else if context.viewingContext.isBookmark {
                            self.location = context.viewingContext.bookmarkLocation
                        }
                    } else {
                        self.location = .base
                    }
                    
                    fetch.perform()
                } label: {
                    Text(viewableHosts[index])
                    Image(systemName: imageName)
                }
                .buttonStyle(.plain)
            }
        } label: {
            Text(currentModel?.host(for: location) ?? "")
#if os(iOS)
            Image(systemName: "chevron.up.chevron.down")
#endif
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .frame(maxWidth: Device.isMacOS ? 100 : nil)
    }
}
