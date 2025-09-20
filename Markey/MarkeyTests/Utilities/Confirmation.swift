//
//  Confirmation.swift
//  Markey
//
//  Created by Kerstin Haustein on 20/09/2025.
//

import XCTest

/// wraps XCTestExpectation in Swift Testing style confirmation since await confirmation() does not currently work reliably with combine
protocol Confirmation {}

extension Confirmation {
    func confirm(comment: String) -> XCTestExpectation {
        XCTestExpectation(description: comment)
    }

    func confirmation(_ confirmation: XCTestExpectation,
                      body: @escaping () -> Void) async {
        body()
        await XCTWaiter().fulfillment(of: [confirmation], timeout: 1.0)
    }
}
