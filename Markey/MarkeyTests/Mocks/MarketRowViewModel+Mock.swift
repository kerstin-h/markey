//
//  MarketRowViewModel+Mock.swift
//  Markey
//
//  Created by Kerstin Haustein on 27/09/2025.
//

@testable import Markey

extension MarketRowViewModel {
    convenience init(stockName: String,
                     lastPrice: String,
                     changePercent: String,
                     dataFormatter: DataFormatter = DataFormatter()) {
        let marketPrice = MarketPrice(stockName: stockName, lastPrice: lastPrice, changePercent: changePercent)
        self.init(dataFormatter: dataFormatter,
                  marketPrice: marketPrice)
    }

    static func mock(stockName: String = "",
                     lastPrice: String = "",
                     changePercent: String = "") -> MarketRowViewModel {
        MarketRowViewModel(stockName: stockName, lastPrice: lastPrice, changePercent: changePercent)
    }
}

extension MarketRowViewModel: @retroactive Equatable {
    public static func == (lhs: MarketRowViewModel, rhs: MarketRowViewModel) -> Bool {
        lhs.stockName == rhs.stockName && lhs.price == rhs.price
    }
}
