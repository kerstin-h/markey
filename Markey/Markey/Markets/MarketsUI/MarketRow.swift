//
//  MarketRow.swift
//  Markey
//
//  Created by Kerstin Haustein on 27/09/2025.
//

import SwiftUI

struct MarketRow: View {
    @ObservedObject private var viewModel: MarketRowViewModel

    init(_ viewModel: MarketRowViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            Text(viewModel.stockName)
            PricesView(viewModel.price)
        }
    }
}

private struct PricesView: View {
    private let price: Price

    init(_ price: Price) {
        self.price = price
    }

    var body: some View {
        Group {
            Text(price.lastPrice)
            Text(price.changePercent)
        }
    }
}
