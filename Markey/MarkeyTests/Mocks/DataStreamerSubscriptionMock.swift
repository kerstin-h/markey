//
//  DataStreamerSubscriptionMock.swift
//  Markey
//
//  Created by Kerstin Haustein on 13/09/2025.
//

import Combine
@testable import Markey

actor DataStreamerSubscriptionMock: DataStreamerSubscriptionProtocol {
    private let dataPublisher = PassthroughSubject<MarketPrice, StreamingError>()

    var subscribed = false

    lazy var streamingDataPublisher: AnyPublisher<MarketPrice, StreamingError> = {
        dataPublisher.eraseToAnyPublisher()
    }()
    
    func publish(_ data: MarketPrice) {
        dataPublisher.send(data)
    }

    func publish(_ error: StreamingError) {
        dataPublisher.send(completion: .failure(error))
    }

    func subscribe() {
        subscribed = true
    }

    func unsubscribe() {
        subscribed = false
    }
}
