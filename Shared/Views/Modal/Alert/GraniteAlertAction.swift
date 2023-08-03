import Foundation
import SwiftUI

public protocol GraniteAlertActionGroup {
    
    var actions : [GraniteAlertAction] { get }
    
}

extension GraniteAlertAction : GraniteAlertActionGroup {
   
    public var actions: [GraniteAlertAction] {
        [self]
    }
    
}

extension Array: GraniteAlertActionGroup where Element == GraniteAlertAction {
  
    public var actions: [GraniteAlertAction] {
        self
    }
    
}

@resultBuilder public struct GraniteAlertActionBuilder {
    
    public static func buildBlock() -> [GraniteAlertAction] {
        []
    }
    
    public static func buildBlock(_ action : GraniteAlertAction) -> [GraniteAlertAction] {
        [action]
    }
    
    public static func buildBlock(_ actions: GraniteAlertActionGroup...) -> [GraniteAlertAction] {
        actions.flatMap { $0.actions }
    }
    
    public static func buildEither(first action: [GraniteAlertAction]) -> [GraniteAlertAction] {
        action
    }
    
    public static func buildEither(second action: [GraniteAlertAction]) -> [GraniteAlertAction] {
        action
    }
    
    public static func buildOptional(_ actions: [GraniteAlertActionGroup]?) -> [GraniteAlertAction] {
        actions?.flatMap { $0.actions } ?? []
    }
    
}

public struct GraniteAlertAction : Identifiable, Equatable {
    
    public enum Kind {
        case normal
        case destructive
    }
    
    public static func == (lhs: GraniteAlertAction, rhs: GraniteAlertAction) -> Bool {
        lhs.id == rhs.id
    }
    
    public let content : AnyView
    public let kind : Kind
    public let handler : () -> Void
    public let disableInteraction : Bool
    
    public let id = UUID()
    
    public init<Content : View>(@ViewBuilder content : () -> Content) {
        self.content = AnyView(content())
        
        self.kind = .normal
        self.handler = {}
        self.disableInteraction = true
    }
    
    public init(title : LocalizedStringKey, kind : Kind = .normal, handler : @escaping () -> Void = {}) {
        self.content = AnyView(Text(title))
        
        self.kind = kind
        self.handler = handler
        self.disableInteraction = false
    }
    
}
