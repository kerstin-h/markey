//
//  MarketStreamingDataProvider.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//
//

import Foundation
import Combine

class MarketStreamingDataProvider {
    private let pricesPublisher = PassthroughSubject<MarketPrice, Never>()
    
    private let streamingService: DataStreamingServiceProtocol
    
    private var priceSubscriptions = Set<AnyCancellable>()
    private var streamerSubscription: DataStreamerSubscriptionProtocol?
    
    lazy var marketPricesPublisher: AnyPublisher<MarketPrice, Never> = {
        pricesPublisher.eraseToAnyPublisher()
    }()
    
    init(streamingService: DataStreamingServiceProtocol) {
        self.streamingService = streamingService
    }
    
    func startStreaming() {
        if streamerSubscription == nil {
            streamerSubscription = streamingService.newSubscription()
        }
        guard let streamerSubscription else { return }
        streamerSubscription.streamingDataPublisher.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] priceUpdate in
            self?.pricesPublisher.send(priceUpdate)
        }).store(in: &priceSubscriptions)
        streamingService.startStreaming(subscription: streamerSubscription)
    }
    
    func stopStreaming() {
        streamerSubscription?.unsubscribe()
        priceSubscriptions.removeAll()
    }
}
