//
//  MarketPrice+Mock.swift
//  Markey
//
//  Created by Kerstin Haustein on 13/09/2025.
//

@testable import Markey

extension MarketPrice {
    static func mock(stockName: String = "", lastPrice: String = "", changePercent: String = "") -> MarketPrice {
        MarketPrice(stockName: stockName, lastPrice: lastPrice, changePercent: changePercent)
    }
}
