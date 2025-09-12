//
//  ContentView.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @ObservedObject private var viewModel: ContentViewModel
    
    init(viewModel: ContentViewModel) {
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
    ContentView(viewModel: ContentViewModel.mock)
}

extension ContentViewModel {
    static var mock: ContentViewModel {
        .init(streamingDataProvider: .init())
    }
}
