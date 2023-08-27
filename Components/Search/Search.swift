import Granite
import SwiftUI
import LemmyKit

struct Search: GraniteComponent {
    @Command var center: Center
    
    @Relay var config: ConfigService
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var conductor: SearchConductor = .init()
    
    let community: Community?
    let isModal: Bool
    
    init(_ community: Community? = nil, isModal: Bool = false) {
        self.community = community
        self.isModal = isModal
    }
}
