/**
 This file is part of the Reductio package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import Foundation

internal final class TextRank<T: Hashable> {

    typealias Node      = [T: Float]
    typealias Edge      = [T: Float]
    typealias Graph     = [T: [T]]
    typealias Matrix    = [T: Node]

    fileprivate var graph       = Graph()
    fileprivate var outlinks    = Edge()
    fileprivate var nodes       = Node()
    fileprivate var weights     = Matrix()

    let score: Float = 0.15
    let damping: Float = 0.85
    let convergence: Float = 0.01

    func add(edge from: T, to: T, weight: Float = 1.0) {
        if from == to { return }

        add(node: from, to: to)
        add(weigth: from, to: to, weight: weight)
        increment(outlinks: from)
    }

    func execute() -> Node {
        var stepNodes = iteration(nodes)
        while !convergence(stepNodes, nodes: nodes) {
            nodes = stepNodes
            stepNodes = iteration(nodes)
        }
        return nodes
    }

    //  Performs one iteration to calculate
    //  the PageRank ranking for all nodes.
    private func iteration(_ nodes: Node) -> Node {
        var vertex = Node()
        for (node, links) in graph {
            let score: Float = links.reduce(0.0) { $0 + (nodes[$1] ?? 0) / (outlinks[$1] ?? 1) * weights[$1, node] }
            vertex[node] = (1-damping/nodes.count) + damping * score
        }
        return vertex
    }

    // Check for convergence
    private func convergence(_ current: Node, nodes: Node) -> Bool {
        if current == nodes { return true }

        let total: Float = nodes.reduce(0.0) {
            return $0 + pow((current[$1.0] ?? 1) - $1.1, 2)
        }
        return sqrtf(total/current.count) < convergence
    }
}

private extension TextRank {

    func increment(outlinks source: T) {
        if let links = outlinks[source] {
            outlinks[source] = links + 1
        } else {
            outlinks[source] = 1
        }
    }

    func add(node from: T, to: T) {
        if var node = graph[to] {
            node.append(from)
            graph[to] = node
        } else {
            graph[to] = [from]
        }

        nodes[from] = score
        nodes[to] = score
    }

    func add(weigth from: T, to: T, weight: Float) {
        if weights[from] == nil {
            weights[from] = Node()
            weights[from]![to] = weight
        } else {
            weights[from]![to] = weight
        }
    }
}

private extension Dictionary {

    subscript (key: Key) -> Float {
        return self[key] as? Float ?? 0
    }

    subscript (from: Key, to: Key) -> Float {
        guard
            let row = self[from] as? [Key: Float],
            let value = row[to]
        else {
                return 0
        }
        return value
    }

    var count: Float {
        return Float(self.count as Int)
    }
}
