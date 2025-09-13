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
            if (ProcessInfo.processInfo.environment["XCTestSessionIdentifier"] != nil) {
                EmptyView()
            } else {
                let coordinator = RootCoordinator()
                coordinator.instantiate()
            }
        }
    }
}
