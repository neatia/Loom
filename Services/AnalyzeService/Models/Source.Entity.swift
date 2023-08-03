import Foundation
import SwiftUI
import Granite

extension Source {
    typealias IdentifiableBox = Codable & Identifiable
    class Box<T: IdentifiableBox>: Equatable, Codable {
        static func == (lhs: Source.Box<T>, rhs: Source.Box<T>) -> Bool {
            lhs.boxed.id == rhs.boxed.id
        }
        
       let boxed: T
        var parent: T?
        init(_ thingToBox: T, parent: T? = nil) {
            boxed = thingToBox
            self.parent = parent
        }
    }
    
    struct Entity: GraniteModel, Identifiable {
        
        var id: String {
            content
        }
        
        
        var content: String
        var pureContent: String {
            next?.content ?? content
        }
        
        let date: Date
        let kind: Source.Entity.Kind
        
        let next: NextEntityResult?
        var children: [Source.Entity] {
            next?.children ?? []
        }
        
        let isRoot: Bool
        
        init(content: String, raw: String? = nil, kind: Kind = .none, isRoot: Bool = false) {
            var detectedKind: Kind = kind
            
            if let value = raw {
                
                if kind == .none {
                    detectedKind =  Source.Entity.Kind.getKind(Source.Entity.getType(value))
                }
                
                if detectedKind != .none {
                    next = Source.Entity.findNext(value)
                } else {
                    next = nil
                }
            } else {
                next = nil
            }
            
            //Grab all data between any tag and zip
            let sanitized = content.match(RegexPatterns.plain).compactMap {
                $0.last?.value
            }.joined()
            
            self.content = (sanitized.isEmpty ? content : sanitized).replacingOccurrences(of: "&nbsp;", with: " ")
            
            self.kind = detectedKind
            self.isRoot = isRoot
            
            date = .init()
        }
    }
}
