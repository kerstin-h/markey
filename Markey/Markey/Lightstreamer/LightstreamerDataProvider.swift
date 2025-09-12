//
//  LightstreamerDataProvider.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//
//  Lightstreamer docs: https://github.com/Lightstreamer/Lightstreamer-lib-client-swift/tree/6.2.1
//

import Combine
import LightstreamerClient

final class LightstreamerDataProvider {
    private enum Fields: String {
        case stockName = "stock_name"
        case lastPrice = "last_price"
    }
    
    private var client: LightstreamerClient?
    private var subscription: LSSubscription?

    let pricesPublisher = PassthroughSubject<MarketPrice, Never>()

    func instantiate(endpoint: String) {
        self.client = LightstreamerClient(
            serverAddress: endpoint,
            adapterSet: "DEMO"
        )
    }

    func connect() {
        client?.connect()
    }

    func subscribe() {
        guard let client else { return }
        let items = [ "item1", "item2", "item3" ]
        let fields = [ Fields.stockName.rawValue, Fields.lastPrice.rawValue ]
        if subscription == nil {
            subscription = Subscription(subscriptionMode: .MERGE, items: items, fields: fields)
            subscription?.dataAdapter = "QUOTE_ADAPTER"
            subscription?.requestedSnapshot = .yes
        }
        guard let subscription else { return }
        client.subscribe(subscription)
        subscription.addDelegate(self)
    }

    func disconnect() {
        client?.disconnect()
    }

    func unsubscribe() {
        subscription?.removeDelegate(self)
        guard let subscription else { return }
        client?.unsubscribe(subscription)
    }
}

extension LightstreamerDataProvider: SubscriptionDelegate {

    func subscription(_ subscription: LSSubscription, didUpdateItem itemUpdate: ItemUpdate) {
        guard let stockName = itemUpdate.value(withFieldName: Fields.stockName.rawValue),
              let lastPrice = itemUpdate.value(withFieldName: Fields.lastPrice.rawValue) else {
            return
        }
        
        let priceUpdate = MarketPrice(
            stockName: stockName,
            lastPrice: lastPrice
        )
        pricesPublisher.send(priceUpdate)
        print("\(stockName) \(lastPrice)")
    }

    func subscription(_ subscription: LSSubscription, didClearSnapshotForItemName itemName: String?, itemPos: UInt) { }
    
    func subscription(_ subscription: LSSubscription, didLoseUpdates lostUpdates: UInt, forCommandSecondLevelItemWithKey key: String) { }
    
    func subscription(_ subscription: LSSubscription, didFailWithErrorCode code: Int, message: String?, forCommandSecondLevelItemWithKey key: String) { }
    
    func subscription(_ subscription: LSSubscription, didEndSnapshotForItemName itemName: String?, itemPos: UInt) { }
    
    func subscription(_ subscription: LSSubscription, didLoseUpdates lostUpdates: UInt, forItemName itemName: String?, itemPos: UInt) { }
    
    func subscriptionDidRemoveDelegate(_ subscription: LSSubscription) { }
    
    func subscriptionDidAddDelegate(_ subscription: LSSubscription) { }
    
    func subscriptionDidSubscribe(_ subscription: LSSubscription) { }
    
    func subscription(_ subscription: LSSubscription, didFailWithErrorCode code: Int, message: String?) { }
    
    func subscriptionDidUnsubscribe(_ subscription: LSSubscription) { }
    
    func subscription(_ subscription: LSSubscription, didReceiveRealFrequency frequency: RealMaxFrequency?) { }
}
