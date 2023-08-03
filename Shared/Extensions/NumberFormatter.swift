import Foundation

extension NumberFormatter {
    
    typealias Abbrevation = (threshold: Double, divisor: Double, suffix: String)
    
    static let abbreviations: [Abbrevation] = [(0, 1, ""),
                                               (1000.0, 1000.0, "K"),
                                               (100_000.0, 1_000_000.0, "M"),
                                               (100_000_000.0, 1_000_000_000.0, "B")]
    
    static let abbreviationFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    /**
     Formats number as abbreviated string with suffix.
     -
     598 → 598
     -999 → -999
     1000 → 1K
     -1284 → -1.3K
     9940 → 9.9K
     9980 → 10K
     39900 → 39.9K
     99880 → 99.9K
     399880 → 0.4M
     999898 → 1M
     999999 → 1M
     1456384 → 1.5M
     12383474 → 12.4M
     */
    public static func formatAbbreviated(_ num: Double) -> String {
        let startValue = abs(num)
        
        let abbreviation: Abbrevation = {
            var prevAbbreviation = Self.abbreviations[0]
            for tmpAbbreviation in Self.abbreviations {
                if (startValue < tmpAbbreviation.threshold) {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        }()
        
        let value = num / abbreviation.divisor
        
        Self.abbreviationFormatter.positiveSuffix = abbreviation.suffix
        Self.abbreviationFormatter.negativeSuffix = abbreviation.suffix
        
        return Self.abbreviationFormatter.string(from: NSNumber(value: value))!
    }
    
    static func formatAbbreviated(_ num: Int) -> String {
        NumberFormatter.formatAbbreviated(Double(num))
    }
    
}
