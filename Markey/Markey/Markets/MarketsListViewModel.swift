//
//  MarketsListViewModel.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import Foundation
import Combine

final class MarketsListViewModel: ObservableObject {
    @Published private(set) var marketRowViewModels = [MarketRowViewModel]()

    private let streamingDataProvider: MarketStreamingDataProvider
    private var subscriptions = Set<AnyCancellable>()
    
    init(streamingDataProvider: MarketStreamingDataProvider) {
        self.streamingDataProvider = streamingDataProvider
    }

    private func addPriceUpdate(marketPrice: MarketPrice) {
        if let viewModel = viewModel(for: marketPrice.stockName) {
            viewModel.price = Price(lastPrice: marketPrice.lastPrice, changePercent: marketPrice.changePercent)
        } else {
            marketRowViewModels.append(MarketRowViewModel(marketPrice: marketPrice))
            marketRowViewModels.sort(by: { $0.stockName < $1.stockName })
        }
    }

    private func viewModel(for stockName: String) -> MarketRowViewModel? {
        marketRowViewModels.first(where: { $0.stockName == stockName })
    }

    func startStreaming() {
        streamingDataProvider.marketPricesPublisher.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] marketPrice in
            self?.addPriceUpdate(marketPrice: marketPrice)
        }).store(in: &subscriptions)
        streamingDataProvider.startStreaming()
    }

    func stopStreaming() {
        streamingDataProvider.stopStreaming()
        subscriptions.removeAll()
    }
}
