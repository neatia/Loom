//
//  CGFloat.swift
//  Loom
//
//  Created by PEXAVC on 7/15/23.
//

import Foundation

extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
