//
//  ContentViewModel.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import Combine

final class ContentViewModel: ObservableObject {
    @Published private var markets = [String: String]()

    public var marketList: [MarketPrice] {
        let marketList = markets.sorted(by: { $0.key < $1.key })
        return marketList.map { MarketPrice(stockName: $0.key, lastPrice: $0.value) }
    }
    
    private let streamingDataProvider: LightstreamerDataProvider
    private var credentials: LSCredentials?
    private var subscriptions = Set<AnyCancellable>()
    
    init(streamingDataProvider: LightstreamerDataProvider) {
        self.streamingDataProvider = streamingDataProvider
        self.credentials = LSCredentials()
        streamingDataProvider.pricesPublisher.sink(receiveValue: { [weak self] marketPrice in
            self?.markets[marketPrice.stockName] = marketPrice.lastPrice
        }).store(in: &subscriptions)
    }

    func startStreaming() {
        guard let credentials else { return }
        streamingDataProvider.instantiate(endpoint: credentials.endpoint)
        streamingDataProvider.connect()
        streamingDataProvider.subscribe()
    }

    func stopStreaming() {
        streamingDataProvider.unsubscribe()
        streamingDataProvider.disconnect()
    }
}
