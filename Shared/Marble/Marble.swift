//
//  Marble.swift
//  Loom
//
//  Created by PEXAVC on 8/12/23.
//

import Foundation
import MarbleKit

struct MarbleOptions {
    static var enableFX: Bool = false
    static var fx: MarbleWebGLCatalog.FX = .granite
}
extension MarbleWebGLCatalog.FX {
    var speed: Double {
        switch self {
        case .waves:
            return 0.4
        default:
            return 1.0
        }
    }
}
