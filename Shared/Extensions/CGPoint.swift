//
//  CGPoint.swift
//  Lemur
//
//  Created by Ritesh Pakala on 8/3/23.
//

import Foundation

import SwiftUI

/// A palette of colors for visualizations
struct Palette {
    static func color(for index: Int) -> Color {
        return colors[index % colors.count]
    }
    private static let colors: [Color] = [.red, .green, .cyan, .orange, .yellow, .purple, .pink, .black]
}

extension CGPoint {
    @inlinable
    init(_ x: Double, _ y: Double) {
        self.init(x: x, y: y)
    }
    
    @inlinable
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(lhs.x+rhs.x, lhs.y+rhs.y)
    }
    
    @inlinable
    static prefix func -(point: CGPoint) -> CGPoint {
        return CGPoint(-point.x, -point.y)
    }
    
    @inlinable
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return lhs + (-rhs)
    }
    
    @inlinable
    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }
    
    @inlinable
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(lhs.x*rhs, lhs.y*rhs)
    }
    
    @inlinable
    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(lhs.x/rhs, lhs.y/rhs)
    }
    
    @inlinable
    var distanceSquared: CGFloat { x*x + y*y }
    
    @inlinable
    var distance: CGFloat { distanceSquared.squareRoot() }
}

extension Collection where Element == CGPoint {
    func meanPoint() -> CGPoint? {
        guard count != 0 else { return nil }
        return reduce(.zero, +) / CGFloat(count)
    }
}

