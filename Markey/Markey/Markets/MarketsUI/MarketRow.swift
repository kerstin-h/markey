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
                .accessibilityIdentifier("_Label.MarketName_\(viewModel.stockName.replacingOccurrences(of: " ", with: "_"))")
            PricesView(stockName: viewModel.stockName, price: viewModel.price)
        }
        .font(.system(size: 15))
    }
}

private struct PricesView: View {
    private let stockName: String
    private let price: Price

    init(stockName: String,
         price: Price) {
        self.stockName = stockName
        self.price = price
    }

    var body: some View {
        Group {
            Text(price.lastPrice)
                .accessibilityIdentifier("_Label.LastPrice_\(stockName.replacingOccurrences(of: " ", with: "_"))")
            Text(price.changePercent)
                .accessibilityIdentifier("_Label.ChangePercent_\(stockName.replacingOccurrences(of: " ", with: "_"))")
        }
        .font(.system(size: 15, design: .monospaced))
    }
}
