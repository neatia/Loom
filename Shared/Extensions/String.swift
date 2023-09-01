import Foundation

extension String {
    struct Match {
        let value: String
        let range: NSRange
    }
    
    func match(_ regex: String) -> [[Match]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
            .map { match in
            (0..<match.numberOfRanges).map {
                
                Match(value: match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)), range: match.range(at: $0))
                
            }
        } ?? []
    }
    
    var isNotEmpty: Bool {
        self.isEmpty == false
    }
    
    func suggestions(_ options: [String]) -> [String] {
        guard self.count > 1 else  { return [] }
        
        let text = self
        
        let suggestions: [String] = options
            .filter {
                let range = $0.lowercased().range(of: text.lowercased())
                
//                if let rangeCheck = range {
//                    return rangeCheck.lowerBound == $0.startIndex
//                } else {
//                    return false
//                }
                
                return range?.isEmpty == false
                
            }
        
        return suggestions
    }
    
    func includes(_ options: [String]) -> Bool {
        guard self.count > 1 else  { return false }
        
        let text = self
        
        let suggestions: [String] = options
            .filter {
                let range = text.lowercased().range(of: $0.lowercased())
                
                return range?.isEmpty == false
                
            }
        
        return suggestions.isNotEmpty
    }
    
}

extension Int {
    var asString: String {
        "\(self)"
    }
}

extension String {
    //TODO: choose direction of format
    func localized(_ value: String = "", formatted: Bool = false) -> String {
        String(format: NSLocalizedString("\(self)\(formatted ? " %@" : "")", comment: ""), value)
    }
}

extension String {
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/)|(?<=shorts/))([\\w-]++)"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)

        guard let result = regex?.firstMatch(in: self, range: range) else {
            return nil
        }
        
        return (self as NSString).substring(with: result.range)
    }
}
