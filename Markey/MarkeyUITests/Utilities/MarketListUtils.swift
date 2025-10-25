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
        // Note: +Text concatenation prevents usage of accessibility identifiers.
        static let lightstreamer = app.links["https://www.lightstreamer.com"]
    }

    struct Markets {
        static let marketName = app.staticTexts["_Label.MarketName_Ations_Europe"]
        static let lastPrice = app.staticTexts["_Label.LastPrice_Ations_Europe"]
        static let changePercent = app.staticTexts["_Label.ChangePercent_Ations_Europe"]
    }

    struct Web {
        static let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        static let url = safari.textFields["Address"]
    }
}
