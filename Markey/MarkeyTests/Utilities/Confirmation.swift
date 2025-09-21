//
//  Confirmation.swift
//  Markey
//
//  Created by Kerstin Haustein on 20/09/2025.
//

import XCTest

/// wraps XCTestExpectation in Swift Testing style confirmation since await confirmation() does not currently work reliably with combine
protocol Confirmation: AnyObject {
    var confirm: Confirm? { get }
}

extension Confirmation {
    func newConfirm(comment: String = "") -> Confirm {
        XCTestExpectation(description: comment)
    }

    func confirm() {
        confirm?.fulfill()
    }

    func confirmation(expectedCount: Int = 1,
                      body: @escaping () -> Void) async {
        guard let confirm = confirm as? XCTestExpectation else {
            XCTFail("Test is misconfigured, expected XCTestExpectation")
            return
        }
        confirm.expectedFulfillmentCount = expectedCount
        body()
        await XCTWaiter().fulfillment(of: [confirm], timeout: 1.0)
    }
}

protocol Confirm {
    func fulfill()
}

extension XCTestExpectation: Confirm {}
