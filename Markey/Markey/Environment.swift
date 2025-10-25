//
//  Environment.swift
//  Markey
//
//  Created by Kerstin Haustein on 25/10/2025.
//

import Foundation

enum RunningEnvironment {
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
