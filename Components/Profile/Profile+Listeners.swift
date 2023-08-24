//
//  Profile+Listeners.swift
//  Loom
//
//  Created by PEXAVC on 8/18/23.
//

import Foundation
import Granite
import LemmyKit
import SwiftUI

extension Profile {
    var listeners: Void {
        account
            .center
            .update
            .listen { value in
                if let response = value as? AccountService.Update.ResponseMeta {
                    DispatchQueue.main.async {
                        _state.person.wrappedValue = response.person
                        ModalService.shared.presentModal(GraniteToastView(response.notification))
                    }
                }
            }
    }
}
