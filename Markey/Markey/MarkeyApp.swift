//
//  MarkeyApp.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import SwiftUI
import SwiftData

@main
struct MarkeyApp: App {
    var body: some Scene {
        WindowGroup {
            let coordinator = ContentViewCoordinator()
            coordinator.instantiate()
        }
    }
}
