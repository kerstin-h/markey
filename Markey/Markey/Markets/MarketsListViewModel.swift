//
//  MarketsListViewModel.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import Combine

final class MarketsListViewModel: ObservableObject {
    @Published var markets = [String: String]()

    public var marketList: [MarketPrice] {
        let marketList = markets.sorted(by: { $0.key < $1.key })
        return marketList.map { MarketPrice(stockName: $0.key, lastPrice: $0.value) }
    }
    
    private let streamingDataProvider: LightstreamerDataProvider
    private var subscriptions = Set<AnyCancellable>()
    
    init(streamingDataProvider: LightstreamerDataProvider) {
        self.streamingDataProvider = streamingDataProvider
        streamingDataProvider.pricesPublisher.sink(receiveValue: { [weak self] marketPrice in
            self?.markets[marketPrice.stockName] = marketPrice.lastPrice
        }).store(in: &subscriptions)
        configureLightstreamer()
    }
    
    private func configureLightstreamer() {
        // We create the configuration here so that (in future work) the user can modify these values
        let lsConfiguration = LSConfiguration()
        streamingDataProvider.instantiate(configuration: lsConfiguration)
    }

    func startStreaming() {
        streamingDataProvider.connect()
        streamingDataProvider.subscribe()
    }

    func stopStreaming() {
        streamingDataProvider.unsubscribe()
        streamingDataProvider.disconnect()
    }
}
