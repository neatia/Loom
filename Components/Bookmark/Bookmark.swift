import Granite
import SwiftUI

struct Bookmark: GraniteComponent {
    @Command var center: Center
    
    @Relay var service: BookmarkService
    @Relay var modal: ModalService
    
    @Environment(\.graniteTabSelected) var isTabSelected
    
    let showHeader: Bool
    init(showHeader: Bool = true) {
        self.showHeader = showHeader
        service.preload()
    }
}
