import Granite
import SwiftUI

struct Bookmark: GraniteComponent {
    @Command var center: Center
    
    @Relay var service: BookmarkService
    
    let showHeader: Bool
    init(showHeader: Bool = true) {
        self.showHeader = showHeader
        service.preload()
    }
}
