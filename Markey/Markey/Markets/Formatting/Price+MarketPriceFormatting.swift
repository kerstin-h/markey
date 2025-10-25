//
//  Price+MarketPrice.swift
//  Markey
//
//  Created by Kerstin Haustein on 21/10/2025.
//

extension Price {
    init(marketPrice: MarketPrice, dataFormatter: DataFormatter) {
        self.init(lastPrice: dataFormatter.formatted(price: marketPrice.lastPrice),
                  changePercent: dataFormatter.formatted(percentage: marketPrice.changePercent))
    }
}
