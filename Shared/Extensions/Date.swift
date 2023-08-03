import Foundation

extension String {
    var isoDate: Date? {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: self)
        return date
    }
}

extension String {
    func asDate() -> Date? {
        return Calendar.dateFormatter.date(from: self)
    }
    var serverTimeAsDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+00:00")
        
        let date = dateFormatter.date(from: self)
        return date
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

extension Date {
    var simple: Date {
        self.asString.asDate() ?? self
    }
    var asString: String {
        return Calendar.dateFormatter.string(from: self)
    }
    
    var asProperString: String {
        return Calendar.timeDayProperFormatter.string(from: self)
    }
    
    var asProperFileString: String {
        return Calendar.timeDayProperFileFormatter.string(from: self)
    }
    
    var asStringWithTime: String {
        return Calendar.timeDayFormatter.string(from: self)
    }
    
    var asStringWithTimeLineBreak: String {
        return Calendar.timeDayLineBreakFormatter.string(from: self)
    }
    
    func asStringTimedWithTime(_ second: Int) -> String {
        return self.advanceDateBySeconds(value: second).asStringWithTime
    }
    
    func advanceDate(value: Int = 1) -> Date {
        return Calendar.current.date(byAdding: .day, value: value, to: self) ?? self
    }
    
    func advanceDateHourly(value: Int = 1) -> Date {
        return Calendar.current.date(byAdding: .hour, value: value, to: self) ?? self
    }
    
    func advanceDateBySeconds(value: Int = 1) -> Date {
        return Calendar.current.date(byAdding: .second, value: value, to: self) ?? self
    }
    
    public static var today: Date {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        
        let date: Date = .init()
        
        let dateAsString = formatter.string(from: date)
        
        return formatter.date(from: dateAsString) ?? date
        
    }
    
    func dateComponents() -> (year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: self)
        let month = calendar.component(.month, from: self)
        let year = calendar.component(.year, from: self)
        
        return(year, month, day)
    }
    
    func timeComponents() -> (hour: Int, minute: Int, seconds: Int) {
        let time = Calendar.timeFormatter.string(from: self)
        let components = time.components(separatedBy: ":")
        var hour: Int = 0
        var minute: Int = 0
        var seconds: Int = 0
        if components.count == 3 {
            hour = Int(components[0]) ?? 0
            minute = Int(components[1]) ?? 0
            seconds = Int(components[2]) ?? 0
        }
        return (hour, minute, seconds)
    }
    
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    var dayofTheWeek: Weekday {
        let dayNumber = Calendar.current.component(.weekday, from: self)
        // day number starts from 1 but array count from 0
        return Weekday.init(rawValue: dayNumber - 1) ?? Weekday.unknown
    }
    
    public enum Weekday: Int {
        case sunday
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
        case unknown
        
        var isWeekend: Bool {
            return self == .sunday || self == .saturday
        }
    }
    
    func daysFrom(_ date: Date) -> Int {
        let todaysDate = self
        let latestTickerDate = date
        let components = Calendar.current.dateComponents([.day], from: latestTickerDate, to: todaysDate)
        
        return abs(components.day ?? 0)
    }
    
    func hoursFrom(_ date: Date) -> Int {
        let todaysDate = self
        let latestTickerDate = date
        let components = Calendar.current.dateComponents([.hour], from: latestTickerDate, to: todaysDate)
        
        return abs(components.hour ?? 0)
        
    }
    
    func minutesFrom(_ date: Date) -> Int {
        let diff = Int(date.timeIntervalSince1970 - self.timeIntervalSince1970)

        let hours = diff / 3600
        let minutes = (diff - hours * 3600) / 60
        return minutes
    }
    
    func secondsFrom(_ date: Date) -> Int {
        let diff = abs(Int(date.timeIntervalSince1970 - self.timeIntervalSince1970))

        let hours = diff / 3600
        let seconds = (diff - hours * 3600)
        return seconds
    }
}

//MARK: -- Sorting
extension Array where Element == Date {
    public var sortAsc: [Date] {
        self.sorted(by: { $0.compare($1) == .orderedAscending })
    }
    
    public var sortDesc: [Date] {
        self.sorted(by: { $0.compare($1) == .orderedDescending })
    }
    
    public func filterAbove(_ date: Date) -> [Date] {
        return self.filter( { date.compare($0) == .orderedAscending })
    }
    
    public func filterBelow(_ date: Date) -> [Date] {
        return self.filter( { date.compare($0) == .orderedDescending })
    }
}

//MARK: -- Traversal WIP
extension Date {
    
    func isLessOrEqual(to: Date) -> Bool {
        return to.compare(self) == .orderedDescending || self.compare(to) == .orderedSame
    }
    
    func isGreaterOrEqual(to: Date) -> Bool {
        return to.compare(self) == .orderedAscending || self.compare(to) == .orderedSame
    }
}

//MARK: -- Calendar Configurations
extension Calendar {
    func dateBySetting(timeZone: TimeZone, of date: Date) -> Date? {
        var components = dateComponents(in: self.timeZone, from: date)
        components.timeZone = timeZone
        return self.date(from: components)
    }

    func dateBySettingTimeFrom(timeZone: TimeZone, of date: Date) -> Date? {
        var components = dateComponents(in: timeZone, from: date)
        components.timeZone = self.timeZone
        return self.date(from: components)
    }
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    static var timeFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter
    }
    
    static var timeDayFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "HH:mm:ss // MM/dd"
        return dateFormatter
    }
    
    static var timeDayProperFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }
    
    static var timeDayProperFileFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return dateFormatter
    }
    
    static var timeDayLineBreakFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "MM/dd //\nHH:mm:ss"
        return dateFormatter
    }
}
