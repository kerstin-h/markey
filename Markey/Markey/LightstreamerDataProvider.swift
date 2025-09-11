//
//  LightstreamerDataProvider.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//
//  Lightstreamer docs: https://github.com/Lightstreamer/Lightstreamer-lib-client-swift/tree/6.2.1
//

import LightstreamerClient

struct PriceUpdate {
    let stockName: String
    let lastPrice: Double
}

final class LightstreamerDataProvider {
    private enum Fields: String {
        case stockName = "stock_name"
        case lastPrice = "last_price"
    }
    
    private var client: LightstreamerClient?
    private var subscription: Subscription?

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
        subscription = Subscription(subscriptionMode: .MERGE, items: items, fields: fields)
        guard let subscription else { return }
        subscription.dataAdapter = "QUOTE_ADAPTER"
        subscription.requestedSnapshot = .yes
        client.subscribe(subscription)
        subscription.addDelegate(self)
    }
}

extension LightstreamerDataProvider: SubscriptionDelegate {

    func subscription(_ subscription: Subscription, didUpdateItem itemUpdate: ItemUpdate) {
        print("\(String(describing: itemUpdate.value(withFieldName: Fields.stockName.rawValue))): \(String(describing: itemUpdate.value(withFieldName: Fields.lastPrice.rawValue)))")
    }

    func subscription(_ subscription: Subscription, didClearSnapshotForItemName itemName: String?, itemPos: UInt) { }
    
    func subscription(_ subscription: Subscription, didLoseUpdates lostUpdates: UInt, forCommandSecondLevelItemWithKey key: String) { }
    
    func subscription(_ subscription: Subscription, didFailWithErrorCode code: Int, message: String?, forCommandSecondLevelItemWithKey key: String) { }
    
    func subscription(_ subscription: Subscription, didEndSnapshotForItemName itemName: String?, itemPos: UInt) { }
    
    func subscription(_ subscription: Subscription, didLoseUpdates lostUpdates: UInt, forItemName itemName: String?, itemPos: UInt) { }
    
    func subscriptionDidRemoveDelegate(_ subscription: Subscription) { }
    
    func subscriptionDidAddDelegate(_ subscription: Subscription) { }
    
    func subscriptionDidSubscribe(_ subscription: Subscription) { }
    
    func subscription(_ subscription: Subscription, didFailWithErrorCode code: Int, message: String?) { }
    
    func subscriptionDidUnsubscribe(_ subscription: Subscription) { }
    
    func subscription(_ subscription: Subscription, didReceiveRealFrequency frequency: RealMaxFrequency?) { }
}
