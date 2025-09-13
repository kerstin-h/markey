//
//  MarketStreamingDataProvider.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//
//

import Combine

class MarketStreamingDataProvider {
    private let pricesPublisher = PassthroughSubject<MarketPrice, Never>()
    
    private let streamingService: DataStreamingServiceProtocol
    
    private var priceSubscriptions = Set<AnyCancellable>()
    private var streamerSubscription: DataStreamerSubscriptionProtocol?
    
    var marketPricesPublisher: AnyPublisher<MarketPrice, Never> {
        pricesPublisher.eraseToAnyPublisher()
    }
    
    init(streamingService: DataStreamingServiceProtocol) {
        self.streamingService = streamingService
    }
    
    func startStreaming() {
        if streamerSubscription == nil {
            streamerSubscription = subscribe()
        }
        guard let streamerSubscription else { return }
        streamingService.startStreaming(subscription: streamerSubscription)
    }
    
    func stopStreaming() {
        streamerSubscription?.unsubscribe()
    }
    
    private func subscribe() -> DataStreamerSubscriptionProtocol {
        let streamerSubscription = streamingService.newSubscription()
        streamerSubscription.streamingDataPublisher.sink(receiveValue: { [weak self] priceUpdate in
            self?.pricesPublisher.send(priceUpdate)
        }).store(in: &priceSubscriptions)
        return streamerSubscription
    }
}
