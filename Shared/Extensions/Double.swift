//
//  Double.swift
//  * stoic
//
//  Created by PEXAVC on 12/20/20.
//

import Foundation
import SwiftUI

extension Double {
    var format: Double {
        (self * 100).rounded() / 100
    }
    
    func format(_ places: Int) -> Double {
        var f = "1"
        for _ in 0..<places {
            f += "0"
        }
        return (self * (Double(f) ?? 100)).rounded() / (Double(f) ?? 100)
    }
    
    func randomBetween(_ secondNum: Double) -> Double{
        return Double(arc4random()) / Double(UINT32_MAX) * abs(self - secondNum) + min(self, secondNum)
    }
    
    var display: String {
        String(format: "%.2f", self)
    }
    
    var percent: String {
        String(format: "%.2f%", self*100)
    }
    
    var statusPercentDisplay: String {
        return String(format: "%.2f%%\(self > 0.0 ? "^" : "")", self*100)
    }
    
    var percentRounded: String {
        guard self.isNaN == false else { return "0" }
        return "\(Int(ceil(self*100)))"
    }
    
    var abbreviate: String {
        let isNegative: Bool = self < 0
        let number = abs(self)
        let thousand = number / 1000
        let million = number / 1000000
        let billion = number / 1000000000
        
        if billion >= 1.0 {
            return String(format: "%.2f%b", billion)
        } else if million >= 1.0 {
            return String(format: "%.2f%m", million)
        }
        else if thousand >= 1.0 {
            return String(format: "%.2f%k", thousand)
        }
        else {
            return String(format: "%.2f%", self)
        }
    }
}


