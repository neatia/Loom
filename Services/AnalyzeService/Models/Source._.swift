import Foundation
import Granite
import SwiftUI
import RegexBuilder

struct Source: GraniteModel, Identifiable {
    var id: UUID
    
    var body: [Source.Entity]
    var parts: [Source]
    
    var attributed: LocalizedStringKey {
        var attributedText: String = ""
        
        for part in body {
            switch part.kind {
            case .a(let link):
                attributedText += "[\(part.content)](\(link))"
            case .em:
                attributedText += "*\(part.content)*"
            case .none:
                continue
            default:
                attributedText += part.content
            }
        }
        
        return .init(attributedText)
    }
    
    init(_ html: String) {
        id = .init()
        
        //Fetch body
        let siteBody = html.match(Entity.RegexPatterns.content)
        
        //Strip all text
        let pTags: [[String.Match]] = siteBody.flatMap { values in values.flatMap { $0.value.match(Entity.RegexPatterns.p) } }
        
        let entities: [Source.Entity] = pTags.compactMap {

                var entity: Entity? = nil
                if let body = $0.last?.value {
                    entity = .init(content: body, raw: $0.first?.value, isRoot: true)
                }

                return entity
            }
        
        body = entities
        parts = entities.map { .init($0.children) }
        
    }
    
    init(_ source: [Source.Entity]) {
        self.id = .init()
        self.body = source
        self.parts = []
    }
    
    static var empty: Source {
        .init("")
    }
}
