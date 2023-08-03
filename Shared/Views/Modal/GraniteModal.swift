import Foundation
import SwiftUI

public protocol AnyGraniteModal {
    
    var backgroundView : AnyView { get }
    var modalView : AnyView { get }
    
}

public protocol GraniteModal : AnyGraniteModal, View {
    associatedtype BackgroundBody : View
    
    var backgroundBody : BackgroundBody { get }
    
}

extension GraniteModal {
    
    public var backgroundView: AnyView {
        AnyView(self.backgroundBody)
    }
    
    public var modalView: AnyView {
        AnyView(self)
    }
    
}
