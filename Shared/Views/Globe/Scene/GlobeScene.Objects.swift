//
//  GlobeScene.Objects.swift
//  Loom
//
//  Created by PEXAVC on 8/8/23.
//

import Foundation
import SceneKit
import SwiftUI

extension GlobeScene {
    class func makeCylinder(from: SCNVector3, to: SCNVector3) -> (node: SCNNode, radius: CGFloat)
    {
        let lookAt = to - from
        let height = lookAt.length()
        
        let y = lookAt.normalized()
        let up = lookAt.cross(vector: to).normalized()
        let x = y.cross(vector: up).normalized()
        let z = x.cross(vector: y).normalized()
        let transform = SCNMatrix4(x: x, y: y, z: z, w: from)
        
        //param?
        let thickness: CGFloat = 0.005
        let radius: CGFloat = CGFloat(height) / 2
        
        let geometry = SCNTube(innerRadius: radius - (thickness / 2), outerRadius: radius, height: thickness)
        let childNode = SCNNode(geometry: geometry)
        
        #if os(iOS)
        childNode.transform = SCNMatrix4MakeTranslation(0, Float(height / 2), 0) *
        transform
        #else
        childNode.transform = SCNMatrix4MakeTranslation(0, CGFloat(height / 2), 0) *
        transform
        #endif
        
        childNode.runAction(SCNAction.rotateBy(x: .pi / 2, y: 0, z: 0, duration: 0.0))
        
        //childNode.eulerAngles = .init((Float.pi / 4), Float.pi / 2, 0)
        
        geometry.firstMaterial?.fillMode = .fill
        geometry.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        
        return (childNode, radius)
    }
}

extension SCNNode {
    static func text(
        withString string: String,
        color: Color = .yellow,
        fontSize: Float = 0.1,
        shouldLookAtNode lookAtNode: SCNNode? = nil,
        addAboveExistingNode existingNode: SCNNode? = nil) -> SCNNode {
            
            let text = SCNText(string: string, extrusionDepth: 0.1)
            #if os(iOS)
            text.font = UIFont.systemFont(ofSize: 1.0)
            #else
            text.font = NSFont.systemFont(ofSize: 1.0)
            #endif
            text.flatness = 0.01
            text.firstMaterial?.diffuse.contents = GenericColor(color)
            text.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
            
            let textNode = SCNNode(geometry: text)
            textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
            
            var pivotCorrection = SCNMatrix4Identity
            
            if let lookAtNode = existingNode {
                let constraint = SCNLookAtConstraint(target: lookAtNode)
                constraint.isGimbalLockEnabled = true
                textNode.constraints = [constraint]
                
                // Rotate the text 180 degrees around the Y axis so that it faces the lookAtNode
                pivotCorrection = SCNMatrix4Rotate(pivotCorrection, .pi, 0, 1, 0)
            }
            
            // Change the text node's pivot to be centred rather than bototm left
            let (min, max) = text.boundingBox
            pivotCorrection = SCNMatrix4Translate(pivotCorrection, (max.x - min.x) / 2, 0, 0)
            
            // Apply the pivot correction
            textNode.pivot = pivotCorrection
            
            if let existingNode = existingNode {
                // Add a 0.3m Y axis offset so the text floats above the node
                textNode.position = SCNVector3(0, 0.0005, 0)
                
                //
                existingNode.addChildNode(textNode)
            }
            
            return textNode
        }
}
