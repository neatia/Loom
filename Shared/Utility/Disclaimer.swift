//
//  View+Modal.swift
//  Stoic
//
//  Created by PEXAVC on 6/5/23.
//

import Foundation
import SwiftUI

extension View {
    @MainActor
    func disclaimer(_ text: String, _ modalService: ModalService) -> some View {
        self.onTapGesture {
            modalService.present(GraniteAlertView(message: .init(text)) {
                
                GraniteAlertAction(title: "MISC_DONE")
            })
        }
    }
}
