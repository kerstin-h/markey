//
//  DataFormatter.swift
//  Markey
//
//  Created by Kerstin Haustein on 21/10/2025.
//

import Foundation

struct DataFormatter {
    enum CurrencyCode: String {
        case usd = "USD"
    }
    private static let nilFormatted = "-"
    private let currencyCode: CurrencyCode

    init(currencyCode: CurrencyCode = .usd) {
        self.currencyCode = currencyCode
    }

    func formatted(price: String) -> String {
        let formatted = Decimal(string: price)?.formatted(
            .currency(code: currencyCode.rawValue)
            .presentation(.narrow)
        )
        return formatted ?? Self.nilFormatted
    }

    func formatted(percentage: String) -> String {
        let formatted = Decimal(string: percentage)?.formatted(
            .percent
            .scale(1.0)
            .precision(.fractionLength(2))
        )
        return formatted ?? Self.nilFormatted
    }
}
