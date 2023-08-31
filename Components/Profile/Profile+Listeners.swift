//
//  Profile+Listeners.swift
//  Loom
//
//  Created by PEXAVC on 8/18/23.
//

import Foundation
import Granite
import SwiftUI
import FederationKit

extension Profile {
    var listeners: Void {
        account
            .center
            .update
            .listen(.broadcast("profile")) { value in
                if let response = value as? AccountService.Update.ResponseMeta {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        _state.person.wrappedValue = response.person
                        ModalService.shared.presentModal(GraniteToastView(response.notification))
                    }
                }
            }
    }
}
