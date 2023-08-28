import Foundation

extension NumberFormatter {
    static func formatAbbreviated(_ num: Int) -> String {
        let thousand = 1000
        let million = thousand * thousand
        let billion = million * thousand
        
        switch num {
        case 0..<thousand:
            return "\(num)"
        case thousand..<million:
            let quotient = Double(num) / Double(thousand)
            return "\(quotient.rounded(toPlaces: 1))k"
        case million..<billion:
            let quotient = Double(num) / Double(million)
            return "\(quotient.rounded(toPlaces: 1))m"
        default:
            let quotient = Double(num) / Double(billion)
            return "\(quotient.rounded(toPlaces: 1))b"
        }
    }
}

extension Int {
    var abbreviated: String {
        NumberFormatter.formatAbbreviated(self)
    }
}
