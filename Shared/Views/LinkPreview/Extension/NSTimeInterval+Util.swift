//
//  NSTimeInterval+Util.swift
//  Pods
//
//  Created by 鈴木大貴 on 2016/04/04.
//
//

import Foundation

extension TimeInterval {
    public var minutes: TimeInterval {
        return self * 60
    }
    
    public var hours: TimeInterval {
        return minutes * 60
    }
    
    public var days: TimeInterval {
        return hours * 24
    }
    
    public var weeks: TimeInterval {
        return days * 7
    }
    
    public var months: TimeInterval {
        return days * 30
    }
    
    public var years: TimeInterval {
        return days * 365
    }
}

extension NSNumber {
    @objc public class func minutes(_ time: TimeInterval) -> TimeInterval {
        return time.minutes
    }
    
    @objc public class func hours(_ time: TimeInterval) -> TimeInterval {
        return time.hours
    }
    
    @objc public class func days(_ time: TimeInterval) -> TimeInterval {
        return time.days
    }
    
    @objc public class func weeks(_ time: TimeInterval) -> TimeInterval {
        return time.weeks
    }
    
    @objc public class func months(_ time: TimeInterval) -> TimeInterval {
        return time.months
    }
    
    @objc public class func years(_ time: TimeInterval) -> TimeInterval {
        return time.years
    }
}
