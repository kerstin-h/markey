//
//  Confirmation.swift
//  Markey
//
//  Created by Kerstin Haustein on 20/09/2025.
//

import XCTest

/// Swift Testing confirmation utility for Combine publishers.
///
/// Wraps XCTestExpectation to provide reliable testing of Combine behavior
/// since Swift Testing's confirmation API doesn't work reliably with publishers yet
/// and using a checked continuation will hang if an update is not received.
protocol Confirmation {
    var confirm: Confirm? { get }
}

extension Confirmation {
    func newConfirm(comment: String = "",
                    isInverted: Bool) -> Confirm {
        let confirm = XCTestExpectation(description: comment)
        confirm.isInverted = isInverted
        return confirm
    }

    func confirm() {
        confirm?.fulfill()
    }

    func confirmation(expectedCount: Int = 1,
                      isInverted: Bool = true,
                      body: @escaping () -> Void) async {
        guard let confirm = confirm as? XCTestExpectation else {
            return
        }
        if confirm.expectedFulfillmentCount != expectedCount {
            confirm.expectedFulfillmentCount = expectedCount
        }
        body()
        await XCTWaiter().fulfillment(of: [confirm], timeout: 1.0)
    }
}

protocol Confirm {
    func fulfill()
}

extension XCTestExpectation: Confirm {}
