//
//  MarkeyApp.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import SwiftUI
import SwiftData

private enum Environment {
    case production
    case swiftUIPreviews
    case unitTesting

    init(environment: [String : String] = ProcessInfo.processInfo.environment) {
        if environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self = .swiftUIPreviews
        } else if environment["XCTestSessionIdentifier"] != nil {
            self = .unitTesting
        } else {
            self = .production
        }
    }
}

@main
struct MarkeyApp: App {
    var body: some Scene {
        WindowGroup {
            let environment = Environment()
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
