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

    private let dataFormatter: DataFormatter

    init(dataFormatter: DataFormatter,
         marketPrice: MarketPrice) {
        self.dataFormatter = dataFormatter
        self.stockName = marketPrice.stockName
        self.price = Price(marketPrice: marketPrice, dataFormatter: dataFormatter)
    }
}
