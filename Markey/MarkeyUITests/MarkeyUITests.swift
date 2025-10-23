//
//  MarkeyUITests.swift
//  MarkeyUITests
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import XCTest

final class MarkeyUITests: XCTestCase {
    private lazy var app: XCUIApplication = XCUIApplication()

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {}

    @MainActor
    func testLightstreamerLink() throws {
        XCTAssert(MarketListUtils.Link.lightstreamer.waitForExistence(timeout: 3), "Lightstreamer link should dislay.")
        MarketListUtils.Link.lightstreamer.tap()

        XCTAssertTrue(MarketListUtils.Web.safari.wait(for: .runningForeground, timeout: 5), "Safari should be launched after link tapped.")
        XCTAssertTrue(MarketListUtils.Web.url.waitForExistence(timeout: 3), "A webpage should be displayed.")
        XCTAssertEqual((MarketListUtils.Web.url.value as? String)?.contains("lightstreamer.com"), true, "Lighstreamer url should be displayed.")

        app.activate()
        XCTAssertTrue(app.state == .runningForeground, "App should have launched.")
        XCTAssertTrue(MarketListUtils.Link.lightstreamer.waitForExistence(timeout: 1), "Lightstreamer link should dislay again in app.")
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
