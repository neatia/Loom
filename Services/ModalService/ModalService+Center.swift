import Foundation
import Granite

extension ModalService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            
        }
        
        @Store public var state: State
    }
    
}
