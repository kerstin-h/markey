//
//  Confirmation.swift
//  Markey
//
//  Created by Kerstin Haustein on 20/09/2025.
//

import XCTest

/// wraps XCTestExpectation since await confirmation() does not work reliably with combine
protocol Confirmation {}

extension Confirmation {
    func confirmation(comment: String) -> XCTestExpectation {
        XCTestExpectation(description: comment)
    }

    func completion(confirmation: XCTestExpectation) async {
        await XCTWaiter().fulfillment(of: [confirmation], timeout: 1.0)
    }
}
