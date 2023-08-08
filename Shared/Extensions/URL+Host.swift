//
//  URL+Host.swift
//  Loom
//
//  Created by PEXAVC on 7/15/23.
//

import Foundation

extension URL {
    var hostString: String? {
        let host: String?
        
        /*if #available(macOS 13.0, iOS 16.0, *),
           let sanitized = self.host(percentEncoded: false) {
            host = sanitized
        } else */if let sanitized = self.host {
            host = sanitized
        } else {
            host = nil
        }
        
        return host
    }
}

extension String {
    var host: String {
        guard let url = URL(string: self) else {
            return self
        }
        
        return url.hostString ?? self
    }
}
