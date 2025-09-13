//
//  DataStreamerSubscriptionMock.swift
//  Markey
//
//  Created by Kerstin Haustein on 13/09/2025.
//

import Combine
@testable import Markey

final class DataStreamerSubscriptionMock: DataStreamerSubscriptionProtocol {
    private let dataPublisher = PassthroughSubject<MarketPrice, Never>()
    var streamingDataPublisher: AnyPublisher<Markey.MarketPrice, Never> {
        dataPublisher.eraseToAnyPublisher()
    }
    
    func publish(_ data: MarketPrice) {
        dataPublisher.send(data)
    }
    
    func subscribe() { }
    
    func unsubscribe() { }
}
