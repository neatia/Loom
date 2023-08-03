import Foundation
import Granite

extension Source.Entity {
    
    struct RegexPatterns {
        static var a: String = "<a(.*?)/a>"
        static var aHref: String = "<a\\s+(?:[^>]*?\\s+)?href=([\"\'])(.*?)\\1"
        static var aHrefAlt: String = "href=([\"\'])(.*?)\\1"
        static var em: String = "<em(.*?)/em>"
        static var p: String = "<p(.*?)/p>"
        static var content: String = "(header>)(?s).*(<footer)"
        static var plain: String = ">([^<]*)<"
        static var generic: String = "(<|(&lt;))[^>]+>"
    }
    
    enum Kind: Equatable, Codable {
        case a(String)
        case aBase
        case em
        case span
        case p
        case none
        
        var isLink: Bool {
            switch self {
            case .a:
                return true
            default:
                return false
            }
        }
        
        var link: String {
            switch self {
            case .a(let link):
                return link
            default:
                return ""
            }
        }
        
        static func getKind(_ value: String) -> Kind {
            switch value{
            case "</a>":
                return .aBase
            case "</span>":
                return .span
            case "</em>":
                return .em
            case "</p>", "":
                return .p
            default:
                return .none
            }
        }
        
        var rawValue: String {
            switch self {
            case .none:
                return "none"
            default:
                return "\(String(describing: self))"
            }
        }
    }
}
