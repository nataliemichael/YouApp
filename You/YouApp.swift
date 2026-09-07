//
//  YouApp.swift
//  You
//
//  Created by Natalie Michael on 31/8/2026.
//

import SwiftUI

@main
struct YouApp: App {
    /// The patient's one record store, shared by every screen.
    /// Swapping in the JSON-backed store later changes only this line.
    private let repository = InMemoryHealthRecordRepository()

    var body: some Scene {
        WindowGroup {
            RootView(repository: repository)
        }
    }
}
