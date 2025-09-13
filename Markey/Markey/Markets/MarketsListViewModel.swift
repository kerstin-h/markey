//
//  MarketsListViewModel.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import Combine

final class MarketsListViewModel: ObservableObject {
    @Published private(set) var markets = [String: MarketPrice]()

    public var marketList: [MarketPrice] {
        let marketList = markets.sorted(by: { $0.key < $1.key })
        return marketList.map { $0.value }
    }
    
    private let streamingDataProvider: MarketStreamingDataProvider
    private var subscriptions = Set<AnyCancellable>()
    
    init(streamingDataProvider: MarketStreamingDataProvider) {
        self.streamingDataProvider = streamingDataProvider
        streamingDataProvider.marketPricesPublisher.sink(receiveValue: { [weak self] marketPrice in
            self?.markets[marketPrice.stockName] = marketPrice
        }).store(in: &subscriptions)
    }

    func startStreaming() {
        streamingDataProvider.startStreaming()
    }

    func stopStreaming() {
        streamingDataProvider.stopStreaming()
    }
}
