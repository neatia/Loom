import Granite

struct Bookmark: GraniteComponent {
    @Command var center: Center
    
    @Relay var service: BookmarkService
    @Relay var modal: ModalService
    
    let showHeader: Bool
    init(showHeader: Bool = true) {
        self.showHeader = showHeader
        service.preload()
    }
}
