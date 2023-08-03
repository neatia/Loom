import Granite
import SwiftUI
import Foundation

extension Home {
    struct Snap: GraniteReducer {
        typealias Center = Home.Center
        
        
        func reduce(state: inout Center.State) {
            state.status += .capturing
            state.content.takePhoto()
        }
    }
    
    struct PhotoTaken: GraniteReducer {
        typealias Center = Home.Center
        
        @Payload var meta: CameraContent.Meta?
        
        func reduce(state: inout Center.State) {
            state.status -= .capturing
            state.status += .captured
            state.capturedPhoto = meta?.image
        }
    }
}
