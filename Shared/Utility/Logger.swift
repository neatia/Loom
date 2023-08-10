//
//  Logger.swift
//  Loom
//
//  Created by PEXAVC on 8/7/23.
//

import Foundation
public enum LoomLogLevel: Int32, CustomStringConvertible {
    case panic = 0
    case fatal = 8
    case error = 16
    case warning = 24
    case info = 32
    case verbose = 40
    case debug = 48
    case trace = 56

    public var description: String {
        switch self {
        case .panic:
            return "panic"
        case .fatal:
            return "fault"
        case .error:
            return "error"
        case .warning:
            return "warning"
        case .info:
            return "info"
        case .verbose:
            return "verbose"
        case .debug:
            return "debug"
        case .trace:
            return "trace"
        }
    }
}

extension LoomLogLevel {
    static var level: LoomLogLevel = .debug
}

@inline(__always) public func LoomLog(_ message: CustomStringConvertible,
                                       level: LoomLogLevel = .warning,
                                       file: String = #file,
                                       function: String = #function,
                                       line: Int = #line) {
    if level.rawValue <= LoomLogLevel.level.rawValue {
        let fileName = (file as NSString).lastPathComponent
        print("[Loom] | \(level) | \(fileName):\(line) \(function) | \(message)")
    }
}
