//
//  Paper.swift
//  ZoteroPaperStack
//
//  Created by Konstantin Lackner on 30/01/2026.
//

import Foundation

enum PaperStatus: String, Codable {
    case unread
    case toRead
    case currentlyReading
    case read
}

struct Paper: Identifiable {
    let id: String        // later: Zotero item key
    let title: String
    let authors: String
}

func readingStateURL() -> URL {
    let folder = FileManager.default.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
    )[0]
    let appFolder = folder.appendingPathComponent("ZoteroPaperStack", isDirectory: true)

    try? FileManager.default.createDirectory(
        at: appFolder,
        withIntermediateDirectories: true
    )

    return appFolder.appendingPathComponent("readingState.json")
}

func loadReadingState() -> [String: PaperStatus] {
    let url = readingStateURL()
    guard let data = try? Data(contentsOf: url) else {
        return [:]
    }

    return (try? JSONDecoder().decode([String: PaperStatus].self, from: data)) ?? [:]
}

func saveReadingState(_ state: [String: PaperStatus]) {
    let url = readingStateURL()
    print("Saving readingState to:", url.path)

    do {
        let data = try JSONEncoder().encode(state)
        try data.write(to: url)
    } catch {
        print("Failed to save reading state:", error)
    }
}
