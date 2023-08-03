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
}

extension Int {
    var asString: String {
        "\(self)"
    }
}
