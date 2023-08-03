import SwiftUI

extension Source.Entity {
    struct NextEntityResult: Equatable, Codable {
        let entity: Source.Box<Source.Entity>
        let left: Source.Box<Source.Entity>
        let right: Source.Box<Source.Entity>
        
        var content: String {
            let leftC = left.boxed.next?.content ?? left.boxed.content
            
            let main = entity.boxed.next?.content ?? entity.boxed.content
            
            let rightC = right.boxed.next?.content ?? right.boxed.content
            
            return leftC + main + rightC
        }
        
        var children: [Source.Entity] {
            
            let leftC = left.boxed.next?.children ?? [left.boxed]
            
            let main = entity.boxed.next?.children ?? [entity.boxed]
            
            let rightC = right.boxed.next?.children ?? [right.boxed]
            
            return leftC + main + rightC
        }
    }
    
    static func getType(_ content: String) -> String {
        guard let endTag = content.match(RegexPatterns.generic).last else {
            return ""
        }
        
        let startIndex = endTag.first?.range.location ?? 0
        let startLength = endTag.first?.range.length ?? 0
        
        let i = content.index(content.startIndex, offsetBy: startIndex)
        
        let iRight: String.Index
        
        iRight = content.index(content.startIndex, offsetBy: min(startIndex + startLength, content.count))
        
        let iType = String(content[i..<iRight])
        
        return iType
    }
    
    static func findNext(_ content: String) -> NextEntityResult? {
        if let tag = content.match(RegexPatterns.generic).first {
            let startIndex = tag.first?.range.location ?? 0
            let startLength = tag.first?.range.length ?? 0
            
            let i1 = content.index(content.startIndex, offsetBy: startIndex + startLength)
            let l1 = String(content[i1...])
            
            let iLeft = content.index(content.startIndex, offsetBy: startIndex)
            let left = String(content[..<iLeft])
            
            if let endTag = l1.match(RegexPatterns.generic).last {
                let endIndex = endTag.first?.range.location ?? 0
                let endLength = endTag.first?.range.length ?? 0
                
                let i2 = l1.index(l1.startIndex, offsetBy: endIndex)
                let l2 = String(l1[..<i2])
                
                let iRight: String.Index
                
                iRight = l1.index(l1.startIndex, offsetBy: min(endIndex + endLength, l1.count))
                
                let right = String(l1[iRight...])
                
                let iType = String(l1[i2..<iRight])
                
//                print("left:")
//                print(left)
//                print("main:")
//                print(l2)
//                print("right:")
//                print(right)
//                print("type:")
//                print(iType)
//                print("---------------\n")
                
                var kind = Kind.getKind(iType)
                
                if kind == .aBase,
                   let link = content.match(RegexPatterns.aHrefAlt).first?.last {
                    kind = .a(link.value)
                }
                
                let leftE: Source.Entity = .init(content: left, raw: left)
                
                let result: Source.Entity = .init(content: l2, raw: l2, kind: kind)
                
                let rightE: Source.Entity = .init(content: right, raw: right)
                
                return .init(entity: .init(result),
                             left: .init(leftE, parent: result),
                             right: .init(rightE, parent: result))
            }
            
        }
        
        return nil
    }
}
