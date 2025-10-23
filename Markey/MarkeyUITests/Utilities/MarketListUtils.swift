//
//  MarketListUtils.swift
//  Markey
//
//  Created by Kerstin Haustein on 23/10/2025.
//

import XCTest

final class MarketListUtils {
    private static let app: XCUIApplication = XCUIApplication()

    struct Link {
        // Note: +Text() concatenation prevents usage of accessibility identifiers.
        static let lightstreamer: XCUIElement = app.links["https://www.lightstreamer.com"]
    }

    struct Web {
        static let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        static let url = safari.textFields["Address"]
    }
}
