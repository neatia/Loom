//
//  InfoIconView.swift
//  Stoic
//
//  Created by PEXAVC on 4/30/23.
//

import Foundation
import SwiftUI
import GraniteUI

struct InfoIconView: View {
    var text: LocalizedStringKey
    var modal: ModalService
    var body: some View {
        //TODO: modal bug with macOS (maxHeight)
        VStack {
            Text("i")
                .font(.caption2.bold())
                .background(Circle().strokeBorder(.white, lineWidth: 1).frame(width: 16, height: 16))
        }
        .onTapGesture {
            GraniteHaptic.light.invoke()
            modal.presentModal(GraniteAlertView(message: text) {
                
                GraniteAlertAction(title: "MISC_DONE")
            })
        }
    }
}

extension View {
    func addInfoIcon(text: LocalizedStringKey, spacing: CGFloat = .layer4, _ modalService: ModalService, direction: HorizontalAlignment = .trailing ) -> some View {
        HStack(spacing: spacing) {
            if direction == .leading {
                InfoIconView(text: text, modal: modalService)
            }
            self
            if direction == .trailing {
                InfoIconView(text: text, modal: modalService)
            }
        }
    }
}
