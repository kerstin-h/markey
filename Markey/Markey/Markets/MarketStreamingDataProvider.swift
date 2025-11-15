//
//  MarketStreamingDataProvider.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//
//

import Foundation
import Combine

enum MarketError : Error{
    case streamingFailed
}

class MarketStreamingDataProvider {
    private let pricesPublisher = PassthroughSubject<MarketPrice, MarketError>()

    private let streamingService: DataStreamingServiceProtocol
    
    private var priceSubscriptions = Set<AnyCancellable>()
    private var streamerSubscription: DataStreamerSubscriptionProtocol?
    
    lazy var marketPricesPublisher: AnyPublisher<MarketPrice, MarketError> = {
        pricesPublisher.eraseToAnyPublisher()
    }()
    
    init(streamingService: DataStreamingServiceProtocol) {
        self.streamingService = streamingService
    }

    func startStreaming() async {
        if streamerSubscription == nil {
            streamerSubscription = await streamingService.newSubscription()
        }
        guard let streamerSubscription else { return }
        streamerSubscription.streamingDataPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
            if case .failure = completion {
                self?.pricesPublisher.send(completion: .failure(MarketError.streamingFailed))
            }
        }, receiveValue: { [weak self] priceUpdate in
            self?.pricesPublisher.send(priceUpdate)
        }).store(in: &priceSubscriptions)
        Task {
            await streamingService.startStreaming(subscription: streamerSubscription)
        }
    }
    
    func stopStreaming() {
        streamerSubscription?.unsubscribe()
        priceSubscriptions.removeAll()
    }
}
