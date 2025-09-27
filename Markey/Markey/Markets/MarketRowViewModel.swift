//
//  MarketRowViewModel.swift
//  Markey
//
//  Created by Kerstin Haustein on 27/09/2025.
//

import Combine

final class MarketRowViewModel: ObservableObject {
    let stockName: String
    @Published var price: Price

    init(marketPrice: MarketPrice) {
        self.stockName = marketPrice.stockName
        self.price = Price(lastPrice: marketPrice.lastPrice,
                           changePercent: marketPrice.changePercent)
    }
}
