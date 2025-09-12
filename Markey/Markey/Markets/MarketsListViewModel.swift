//
//  MarketsListViewModel.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import Combine

final class MarketsListViewModel: ObservableObject {
    @Published private var markets = [String: String]()

    public var marketList: [MarketPrice] {
        let marketList = markets.sorted(by: { $0.key < $1.key })
        return marketList.map { MarketPrice(stockName: $0.key, lastPrice: $0.value) }
    }
    
    private let streamingDataProvider: LightstreamerDataProvider
    private var lsConfiguration: LSConfiguration?
    private var subscriptions = Set<AnyCancellable>()
    
    init(streamingDataProvider: LightstreamerDataProvider) {
        self.streamingDataProvider = streamingDataProvider
        streamingDataProvider.pricesPublisher.sink(receiveValue: { [weak self] marketPrice in
            self?.markets[marketPrice.stockName] = marketPrice.lastPrice
        }).store(in: &subscriptions)
        configureLightstreamer()
    }
    
    private func configureLightstreamer() {
        let lsConfiguration = LSConfiguration()
        self.lsConfiguration = lsConfiguration
        streamingDataProvider.instantiate(configuration: lsConfiguration.clientConfig)
    }

    func startStreaming() {
        guard let lsConfiguration else { return }
        streamingDataProvider.connect()
        streamingDataProvider.subscribe(with: lsConfiguration.subscriptionConfig)
    }

    func stopStreaming() {
        streamingDataProvider.unsubscribe()
        streamingDataProvider.disconnect()
    }
}
