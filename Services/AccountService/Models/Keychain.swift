//
//  Keychain.swift
//  Loom
//
//  Created by PEXAVC on 7/19/23.
//

import Foundation

/// Errors that can be thrown when the Keychain is queried.
enum KeychainError: LocalizedError {
    /// The requested item was not found in the Keychain.
    case itemNotFound
    /// Attempted to save an item that already exists.
    /// Update the item instead.
    case duplicateItem
    /// The operation resulted in an unexpected status.
    case unexpectedStatus(OSStatus)
}
