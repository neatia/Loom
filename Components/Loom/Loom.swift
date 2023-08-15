import Granite
import SwiftUI

struct Loom: GraniteComponent {
    @Command var center: Center
    
    @Relay var service: LoomService
    
    init() {
        service.preload()
    }
}
