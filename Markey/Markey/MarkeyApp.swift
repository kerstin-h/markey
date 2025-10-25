//
//  MarkeyApp.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import SwiftUI

@main
struct MarkeyApp: App {
    var body: some Scene {
        WindowGroup {
            let environment = RunningEnvironment()
            switch environment {
            case .production, .swiftUIPreviews:
                let coordinator = RootCoordinator()
                coordinator.instantiate()
            case .unitTesting:
                // avoid connecting to lightstreamer during unit testing
                EmptyView()
            }
        }
    }
}
