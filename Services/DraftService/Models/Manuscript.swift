//
//  Manuscript.swift
//  Lemur
//
//  Created by Ritesh Pakala on 7/22/23.
//

import Granite
import Foundation
import LemmyKit

protocol DraftEntity: GraniteModel, Identifiable, Hashable {
    var title: String { get }
    var kind: DraftKind { get }
}
extension DraftEntity {
    var id: String {
        title + kind.rawValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
enum DraftKind: String, GraniteModel {
    case category
    case manuscript
}

struct Manuscript: DraftEntity {
    let title: String
    var content: String = ""
    
    var imageData: Data? = nil
    var postURL: String = ""
    
    var enableIPFS: Bool = false
    var ipfsContentStyle: Int = 0
    
    var dateCreated: Date = .init()
    var dateUpdated: Date = .init()
    
    var kind: DraftKind {
        .manuscript
    }
}

extension Manuscript {
    static func mock(_ id: Int? = nil) -> Manuscript {
        let enableIPFS = 0.randomBetween(1) == 0
        
        return .init(title: "mock\(id == nil ? "" : "_\(id!)")",
              content: "Mock manuscript",
              imageData: nil,
              postURL: "",
              enableIPFS: enableIPFS,
              ipfsContentStyle: 0.randomBetween(1))
    }
}

struct Category: DraftEntity {
    let title: String
    var manuscriptIDs: [String]
    
    var kind: DraftKind {
        .category
    }
    
    //mutating func update(_ manuscriptIDs: [String]) {
    //    self.manuscriptIDs = manuscriptIDs
    //}
}

extension Category {
    static var uncategorized: Category {
        .init(title: "uncategorized", manuscriptIDs: [])
    }
}
