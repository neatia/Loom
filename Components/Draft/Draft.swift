import Granite

struct Draft: GraniteComponent {
    @Command var center: Center
    @Relay var service: DraftService
    @Relay var modal: ModalService
    
}
