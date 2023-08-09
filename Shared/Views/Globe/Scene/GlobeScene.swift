//
//  GlobeScene.swift
//  Loom
//
//  Created by PEXAVC on 8/8/23.
//

import Foundation
import SceneKit
import CoreImage
import Granite
import SwiftUI

#if os(macOS)
public typealias GenericBezierPath = NSBezierPath
extension NSImage {
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)
        
        return cgImage(forProposedRect: &proposedRect,
                       context: nil,
                       hints: nil)
    }
    
    convenience init?(named name: String) {
        self.init(named: Name(name))
    }
}
#else
public typealias GenericBezierPath = UIBezierPath
#endif

public protocol GlobeNode {
    var nodeId: String { get }
}

class GlobeScene {
    let action: SCNAction = SCNAction.repeatForever(SCNAction.rotateBy(x: -2, y: 2, z: 0, duration: 36))
    let actionWarmer: SCNAction = SCNAction.rotateBy(x: -2, y: 2, z: 0, duration: 1.0)
    
    public var earthNode: SCNNode!
    public var sceneView : SCNView!
    private var cameraNode: SCNNode!
    private var pointCloudNode: SCNNode?
    private var worldMapImage : CGImage {
        guard let path = Bundle.main.path(forResource: "earth-dark", ofType: "jpg") else { fatalError("Could not locate world map image.") }
        guard let image = GraniteImage(contentsOfFile: path)?.cgImage else { fatalError() }
        return image
    }
    
    private lazy var imgData: CFData = {
        guard let imgData = worldMapImage.dataProvider?.data else { fatalError("Could not fetch data from world map image.") }
        return imgData
    }()
    
    private lazy var worldMapWidth: Int = {
        return worldMapImage.width
    }()
    
    public var earthRadius: Double = 1.0 {
        didSet {
            if let earthNode = earthNode {
                earthNode.removeFromParentNode()
                setupGlobe()
            }
        }
    }
    
    
    public var dotSize: CGFloat = 0.005 {
        didSet {
            if dotSize != oldValue {
                setupDotGeometry()
            }
        }
    }
    
    public var enablesParticles: Bool = true {
        didSet {
            if enablesParticles {
                setupParticles()
            } else {
                sceneView.scene?.rootNode.removeAllParticleSystems()
            }
        }
    }
    
    public var particles: SCNParticleSystem? {
        didSet {
            if let particles = particles {
                sceneView.scene?.rootNode.removeAllParticleSystems()
                sceneView.scene?.rootNode.addParticleSystem(particles)
            }
        }
    }
    
    public var background: Color?
    
    public var earthColor: Color = .earthColor {
        didSet {
            if let earthNode = earthNode {
                earthNode.geometry?.firstMaterial?.diffuse.contents = earthColor
            }
        }
    }
    
    public var glowColor: Color = .earthGlow {
        didSet {
            if let earthNode = earthNode {
                earthNode.geometry?.firstMaterial?.emission.contents = glowColor
            }
        }
    }
    
    public var reflectionColor: Color = .earthReflection {
        didSet {
            if let earthNode = earthNode {
                earthNode.geometry?.firstMaterial?.emission.contents = glowColor
            }
        }
    }
    
    public var glowShininess: CGFloat = 1.0 {
        didSet {
            if let earthNode = earthNode {
                earthNode.geometry?.firstMaterial?.shininess = glowShininess
            }
        }
    }
    
    private var dotRadius: CGFloat {
        if dotSize > 0 {
            return dotSize
        }
        else {
            return 0.01 * CGFloat(earthRadius) / 1.0
        }
    }
    
    private var dotCount = 12500
    private var data: [GlobeNode]
    private var root: Int
    public var isReady: Bool = false
    public var isSetup: Bool = false
    
    init(_ data: [GlobeNode] = [], rootIndex root: Int = 0) {
        self.data = data
        self.root = root
        self.isReady = data.isNotEmpty
    }
    
    private func initialize(_ data: [GlobeNode], rootIndex root: Int) {
        self.data = data
        self.root = root
        self.isReady = data.isNotEmpty
    }
    
    func setup(_ data: [GlobeNode] = [], force: Bool = false) {
        if sceneView == nil {
            setupScene()
        }
        
        guard isReady || force else {
            self.initialize(data, rootIndex: root)
            return
        }
        
        guard isSetup == false else {
            return
        }
        
        isSetup = true
        LoomLog("setting up Globe", level: .debug)
        
        if enablesParticles {
            setupParticles()
        }
        setupCamera()
        setupGlobe()
        setupDotGeometry()
        if let background = background {
            setupBackground(color: GenericColor(background))
        }
    }
    
    private func setupScene() {
        let scene = SCNScene()
        sceneView = SCNView()
        
        sceneView.scene = scene
        
        //sceneView.showsStatistics = true
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = true
    }
    
    private func setupParticles() {
        guard let stars = SCNParticleSystem(named: "StarsParticles.scnp", inDirectory: nil) else { return }
        stars.isLightingEnabled = false
        sceneView.scene?.rootNode.addParticleSystem(stars)
    }
    
    private func setupBackground(color: GenericColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = sceneView.bounds
        gradientLayer.colors = [color.cgColor, GenericColor.black.cgColor]
        
#if os(iOS)
        sceneView.layer.insertSublayer(gradientLayer, at: 0)
#else
        sceneView.layer?.insertSublayer(gradientLayer, at: 0)
#endif
    }
    
    private func setupCamera() {
        self.cameraNode = SCNNode()
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        
        sceneView.scene?.rootNode.addChildNode(cameraNode)
    }
    
    private func setupGlobe() {
        self.earthNode = EarthNode(radius: earthRadius, earthColor: earthColor, earthGlow: glowColor, earthReflection: reflectionColor)
        sceneView.scene?.rootNode.addChildNode(earthNode)
    }
    
    private func setupDotGeometry() {
        self.generateTextureMap(radius: CGFloat(earthRadius)) { [weak self] (map, indices) in
            var mutableIndices: [Int] = indices
            let dotColor = GenericColor(white: 1, alpha: 1)
            
            
            let dotGeometry = SCNSphere(radius: dotRadius)
            
            dotGeometry.firstMaterial?.diffuse.contents = dotColor
            dotGeometry.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
            
            var connectionNodes = [SCNNode]()
            var textNodes = [SCNNode]()
            
            //Root node setup
            
            let rootNodeIndex: Int = 0.randomBetween(indices.count)//customizable
            let rootSCNNode: SCNNode = SCNNode(geometry: dotGeometry)
            
            if data.count > root {
                let rootNode: GlobeNode = data.remove(at: root)
                rootSCNNode.name = rootNode.nodeId
            }
            
            let rootNodeDotIndex = mutableIndices.remove(at: rootNodeIndex)
            rootSCNNode.position = map[rootNodeDotIndex].position
            
            let node: SCNNode = .text(withString: "!", color: .red)
            node.position = rootSCNNode.position
            textNodes.append(node)
            //
            
            var positions: [SCNVector3] = [rootSCNNode.position]
            var dotNodes: [SCNNode] = [rootSCNNode]
            
            let segment: Int = data.isEmpty ? .max : max(data.count, indices.count) / min(data.count, indices.count)
            
            for (index, i) in indices.enumerated() {
                let dotNode = SCNNode(geometry: dotGeometry)
                dotNode.position = map[i].position
                positions.append(dotNode.position)
                
                //TODO: % is not fully accurate will miss some
                //children nodes
                if index % segment == 0,
                          data.isNotEmpty {

                    let node = data.removeFirst()
                    dotNode.name = node.nodeId
                    //LoomLog("linking: \(node.nodeId)", level: .debug)
                    let line = GlobeScene.makeCylinder(from: dotNode.position, to: rootSCNNode.position)
                    line.node.name = node.nodeId
                    line.node.geometry?.firstMaterial?.diffuse.contents = GenericColor(Brand.Colors.yellow.opacity(0.75))

                    connectionNodes.append(line.node)

//                    let textNode: SCNNode = .text(withString: "@"+node.nodeId, color: .yellow, fontSize: 0.05, addAboveExistingNode: line.node)
//                    textNode.position.z += line.radius
//                    textNode.runAction(SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 0.0))
//                    textNodes.append(textNode)
                }
                dotNodes.append(dotNode)
                
            }
            
            LoomLog("setting up: \(dotNodes.count) dot nodes", level: .debug)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                let dotPositions = positions as NSArray
                let dotIndices = NSArray()
                let source = SCNGeometrySource(vertices: dotPositions as! [SCNVector3])
                let element = SCNGeometryElement(indices: dotIndices as! [Int32], primitiveType: .point)
                
                let pointCloud = SCNGeometry(sources: [source], elements: [element])
                
                let pointCloudNode = SCNNode(geometry: pointCloud)
                for dotNode in dotNodes {
                    pointCloudNode.addChildNode(dotNode)
                }
                
                for connectNode in connectionNodes {
                    pointCloudNode.addChildNode(connectNode)
                }
                
//                for textNode in textNodes {
//                    pointCloudNode.addChildNode(textNode)
//                }
                
                self.pointCloudNode = pointCloudNode
                
                self.sceneView.scene?.rootNode.addChildNode(pointCloudNode)
                
                self.animate()
            }
        }
    }
    
    private func generateTextureMap(radius: CGFloat, completion: ([(position: SCNVector3, x: Int, y: Int)], [Int]) -> ()) {
        var textureMap = [(position: SCNVector3, x: Int, y: Int)]()
        var pixelIndices: [Int] = []
        textureMap.reserveCapacity(dotCount)
        let doubleDotCount = Double(dotCount)
        let floatWorldMapImageHeight = CGFloat(worldMapImage.height)
        let floatWorldMapImageWidth = CGFloat(worldMapImage.width)
        for i in 0...dotCount {
            let phi = acos(-1 + (2 * Double(i)) / doubleDotCount)
            let theta = sqrt(doubleDotCount * Double.pi) * phi
            
            let x = sin(phi) * cos(theta)
            let y = sin(phi) * sin(theta)
            let z = cos(phi)
            
            let u = CGFloat(theta) / (2 * CGFloat.pi)
            let v = CGFloat(phi) / CGFloat.pi
            
            if u.isNaN || v.isNaN {
                return
            }
            
            let xPixel = Int(u * floatWorldMapImageWidth)
            let yPixel = Int(v * floatWorldMapImageHeight)
            
#if os(iOS)
            textureMap.append((position: SCNVector3(x: Float(x) * Float(radius), y: Float(y) * Float(radius), z: Float(z) * Float(radius)), x: xPixel, y: yPixel))
#else
            textureMap.append((position: SCNVector3(x: x * radius, y: y * radius, z: z * radius), x: xPixel, y: yPixel))
#endif
            
            let pixelColor = self.getPixelColor(x: Int(xPixel), y: Int(yPixel))
            
            // threshold to determine if the pixel in the earth-dark.jpg represents terrain (0.03 represents rgb(7.65,7.65,7.65), which is almost black)
            //customizable?
            let threshold: CGFloat = 0.03
            if pixelColor.red < threshold && pixelColor.green < threshold && pixelColor.blue < threshold {
                pixelIndices.append(textureMap.count - 1)
            }
        }
        completion(textureMap, pixelIndices)
    }
    
    private func getPixelColor(x: Int, y: Int) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(imgData)
        let pixelInfo: Int = ((worldMapWidth * y) + x) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo + 1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo + 2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo + 3]) / CGFloat(255.0)
        
        return (r, g, b, a)
    }
}

extension GlobeScene {
    func animate() {
        //pointCloudNode?.runAction(action)
    }
    
    public func destroy() {
        self.earthNode.removeAllActions()
        self.earthNode.cleanup()
        self.cameraNode.removeAllActions()
        self.cameraNode.cleanup()
        self.sceneView.scene?.rootNode.removeAllActions()
        self.sceneView.scene?.rootNode.cleanup()
    }
}


extension Color {
    static var earthColor: Color {
        return Color(red: 0.227, green: 0.133, blue: 0.541)
    }
    
    static var earthGlow: Color {
        Color(red: 0.133, green: 0.0, blue: 0.22)
    }
    
    static var earthReflection: Color {
        Color(red: 0.227, green: 0.133, blue: 0.541)
    }
}

extension SCNNode {
    public func cleanup() {
        for child in childNodes {
            child.cleanup()
        }
        geometry = nil
        removeFromParentNode()
    }
}



