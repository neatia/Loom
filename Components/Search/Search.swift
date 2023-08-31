import Granite
import SwiftUI
import FederationKit

struct Search: GraniteComponent {
    @Command var center: Center
    
    @Relay var config: ConfigService
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var conductor: SearchConductor = .init()
    
    let community: FederatedCommunity?
    let isModal: Bool
    
    init(_ community: FederatedCommunity? = nil, isModal: Bool = false) {
        self.community = community
        self.isModal = isModal
    }
}
