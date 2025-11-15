//
//  DataStreamerSubscription.swift
//  Markey
//
//  Created by Kerstin Haustein on 13/09/2025.
//

import Combine
import LightstreamerClient

enum StreamingError: Error {
    case subscriptionFailure(code: Int, message: String?)
}

protocol DataStreamerSubscriptionProtocol: Actor {
    var streamingDataPublisher: AnyPublisher<MarketPrice, StreamingError> { get }

    func subscribe()
    func unsubscribe()
}

actor DataStreamerSubscription: DataStreamerSubscriptionProtocol {
    private weak var client: LightstreamerClientProtocol?
    private let dataPublisher = PassthroughSubject<MarketPrice, StreamingError>()
    private let subscription: LSSubscription
    
    lazy var streamingDataPublisher: AnyPublisher<MarketPrice, StreamingError> = {
        dataPublisher.eraseToAnyPublisher()
    }()
    
    init(client: LightstreamerClientProtocol,
         subscription: LSSubscription) {
        self.client = client
        self.subscription = subscription
    }
    
    func subscribe() {
        client?.subscribe(subscription)
        subscription.addDelegate(self)
    }

    func unsubscribe() {
        subscription.removeDelegate(self)
        client?.unsubscribe(subscription)
    }
}

extension DataStreamerSubscription: SubscriptionDelegate {
    nonisolated func subscription(_ subscription: LSSubscription,
                      didUpdateItem itemUpdate: ItemUpdate) {
        guard let stockName = itemUpdate.value(withFieldName: Fields.stockName.rawValue),
              let lastPrice = itemUpdate.value(withFieldName: Fields.lastPrice.rawValue),
              let changePercent = itemUpdate.value(withFieldName: Fields.percentChange.rawValue) else {
            return
        }
        let priceUpdate = MarketPrice(stockName: stockName, lastPrice: lastPrice, changePercent: changePercent)
        Task {
            await self.dataPublisher.send(priceUpdate)
        }
    }

    nonisolated func subscription(_ subscription: LSSubscription, didFailWithErrorCode code: Int, message: String?) {
        let error = StreamingError.subscriptionFailure(code: code, message: message)
        Task {
            await dataPublisher.send(completion: .failure(error))
        }
    }

    nonisolated func subscription(_ subscription: LSSubscription, didClearSnapshotForItemName itemName: String?, itemPos: UInt) {}

    nonisolated func subscription(_ subscription: LSSubscription, didLoseUpdates lostUpdates: UInt, forCommandSecondLevelItemWithKey key: String) {}

    nonisolated func subscription(_ subscription: LSSubscription, didFailWithErrorCode code: Int, message: String?, forCommandSecondLevelItemWithKey key: String) {}

    nonisolated func subscription(_ subscription: LSSubscription, didEndSnapshotForItemName itemName: String?, itemPos: UInt) {}

    nonisolated func subscription(_ subscription: LSSubscription, didLoseUpdates lostUpdates: UInt, forItemName itemName: String?, itemPos: UInt) {}

    nonisolated func subscriptionDidRemoveDelegate(_ subscription: LSSubscription) {}

    nonisolated func subscriptionDidAddDelegate(_ subscription: LSSubscription) {}

    nonisolated func subscriptionDidSubscribe(_ subscription: LSSubscription) {}

    nonisolated func subscriptionDidUnsubscribe(_ subscription: LSSubscription) {}

    nonisolated func subscription(_ subscription: LSSubscription, didReceiveRealFrequency frequency: RealMaxFrequency?) {}
}

