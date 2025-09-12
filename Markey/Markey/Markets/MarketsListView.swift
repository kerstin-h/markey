//
//  MarketsListView.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import SwiftUI
import SwiftData

struct MarketsListView: View {
    @ObservedObject private var viewModel: MarketsListViewModel
    
    init(viewModel: MarketsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List(viewModel.marketList, id: \.stockName) { market in
            HStack(spacing: .zero) {
                Text(market.stockName)
                Spacer()
                Text(market.lastPrice)
            }
        }
        .onAppear {
            viewModel.startStreaming()
        }
        .onDisappear {
            viewModel.stopStreaming()
        }
    }
}

#Preview {
    MarketsListView(viewModel: MarketsListViewModel.mock)
}

extension MarketsListViewModel {
    static var mock: MarketsListViewModel {
        .init(streamingDataProvider: .init())
    }
}
