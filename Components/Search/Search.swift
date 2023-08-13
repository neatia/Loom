import Granite
import SwiftUI
import LemmyKit

struct Search: GraniteComponent {
    @Command var center: Center
    @Relay var modal: ModalService
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var conductor: SearchConductor = .init()
    
    let community: Community?
    
    init(_ community: Community?) {
        self.community = community
    }
}
