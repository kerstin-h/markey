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
    func testStreaming() throws {
        XCTAssert(MarketListUtils.Markets.marketName.waitForExistence(timeout: 3), "Market name should dislay.")
        XCTAssertEqual(MarketListUtils.Markets.marketName.label, "Ations Europe", "Market name should dislay correctly.")
        XCTAssert(MarketListUtils.Markets.lastPrice.exists, "Last price value should dislay.")
        XCTAssert(MarketListUtils.Markets.changePercent.exists, "Change percent value should dislay.")
        let lastPrice = MarketListUtils.Markets.lastPrice.label
        let lastPriceChanged = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "label != %@", lastPrice),
            object: MarketListUtils.Markets.lastPrice
        )
        let changePercent = MarketListUtils.Markets.changePercent.label
        let changePercentChanged = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "label != %@", changePercent),
            object: MarketListUtils.Markets.changePercent
        )
        let result = XCTWaiter().wait(for: [lastPriceChanged, changePercentChanged], timeout: 5)
        XCTAssertEqual(result, .completed, "Last price and change percent should have updated via streaming.")
    }

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
}
