//
//  Paper.swift
//  ZoteroPaperStack
//
//  Created by Konstantin Lackner on 30/01/2026.
//

import Foundation

enum PaperStatus: String {
    case unread
    case currentlyReading
    case toRead
    case read
}

struct Paper: Identifiable {
    let id: String        // later: Zotero item key
    let title: String
    let authors: String
    var status: PaperStatus
}
