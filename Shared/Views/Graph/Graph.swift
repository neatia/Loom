//
//  Graph.swift
//
//  Created by Ray Fix on 7/18/19.
//  Copyright © 2019-2021 Ray Fix. All rights reserved.
//

import Foundation
import CoreGraphics

/// A node represents a vertex of the graph (a dot)
struct Node: Codable, Identifiable {
    var id: String
    var group: Int
    
    // Normalized space
    var position: CGPoint
    var velocity: CGPoint
    var isInteractive: Bool
    
    enum CodingKeys: CodingKey {
        case id, group, position, velocity
    }
    
    init(id: String, group: Int, position: CGPoint, velocity: CGPoint, isInteractive: Bool) {
        self.id = id
        self.group = group
        self.position = position
        self.velocity = velocity
        self.isInteractive = isInteractive
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.group = try container.decode(Int.self, forKey: .group)
        self.position = try container.decodeIfPresent(CGPoint.self, forKey: .position) ?? .zero
        self.velocity = try container.decodeIfPresent(CGPoint.self, forKey: .velocity) ?? .zero
        self.isInteractive = false
    }
}

/// A link is the edge between two nodes
struct Link: Codable {
    var source: String
    var target: String
    var value: Int
}

/// A graph is a collection of nodes and links between the nodes
struct Graph: Codable {
    var nodes: [Node]
    var links: [Link]
}

/// Loading extensions of Graph that are part of the fundamental abstraction
extension Graph {
    enum Error: Swift.Error {
        case fileNotFound(String)
    }
    
    init() {
        let parentNode: Node = .init(id: "main", group: 1, position: .init(0.5, 0.5), velocity: .zero, isInteractive: true)
        
        let childNode1: Node = .init(id: "1", group: 1, position: .init(1, 0), velocity: .zero, isInteractive: true)
        let childNode2: Node = .init(id: "2", group: 1, position: .init(0, 0.5), velocity: .zero, isInteractive: true)
        let childNode3: Node = .init(id: "3", group: 1, position: .init(0, 1), velocity: .zero, isInteractive: true)
        let childNode4: Node = .init(id: "4", group: 1, position: .init(0.5, 0), velocity: .zero, isInteractive: true)
        
        let link1: Link = .init(source: "main", target: "1", value: 1)
        let link2: Link = .init(source: "main", target: "2", value: 2)
        let link3: Link = .init(source: "main", target: "3", value: 3)
        let link4: Link = .init(source: "main", target: "4", value: 4)
        self.nodes = [parentNode, childNode1, childNode2, childNode3, childNode4]
        self.links = [link1, link2, link3, link4]
    }
    
    init(jsonData: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: jsonData)
    }
    
    static func load(filename: String, layout: GraphLayout? = nil, bundle: Bundle = Bundle.main) throws -> Self {
        guard let url = bundle.url(forResource: filename,
                                   withExtension: "json") else {
            throw Error.fileNotFound(filename)
        }
        let data = try Data(contentsOf: url)
        var graph = try Self(jsonData: data)
        
        layout?.update(graph: &graph)
        
        return graph
    }
}

//
//
//Divider()
//
//if nodes.isEmpty {
//    Button {
//        _ = Task.detached { @MainActor in
//            let fedInstances = await Lemmy.instances()
//            let mainNode: Node = .init(id: LemmyKit.host,
//                                       group: 1,
//                                       position: .init(0.5, 0.5),
//                                       velocity: .zero,
//                                       isInteractive: true)
//            
//            let instances = Array(fedInstances?.linked ?? []).prefix(24)
//            
//            var nodes: [Node] = [mainNode]
//            var links: [Link] = []
//            
//            var instanceCount: CGFloat = CGFloat(instances.count)
//            
//            var angle: CGFloat = 24.0 / 360
//            
//            var totalAngle: CGFloat = 0
//            
//            var startX: CGFloat = 0
//            var startY: CGFloat = 0.5
//            
//            var radius: CGFloat = 0.5
//            for (i, instance) in instances.enumerated() {
//                var ratio: CGFloat = CGFloat(i) / instanceCount
//                
//                
//                let instanceNode: Node = .init(id: instance.domain, group: 1, position: .init(x: startX, y: startY), velocity: .zero, isInteractive: true)
//                let link: Link = .init(source: mainNode.id, target: instance.domain, value: instance.id)
//                
//                nodes.append(instanceNode)
//                links.append(link)
//                
//                
//                startX = radius * cos(3.14 * 2 * ratio)
//                startY = radius * sin(3.14 * 2 * ratio)
//                
//                startX += radius
//                startY += radius
//                print("\(startX), \(startY)")
//                
//                totalAngle += angle
//                
//            }
//            
//            self.nodes = nodes
//            self.links = links
//        }
//    } label: {
//        Text("Generate")
//    }
//    .buttonStyle(PlainButtonStyle())
//} else {
//    GraphContainerView(nodes: nodes, links: links)
//}
