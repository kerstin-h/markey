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

class LightstreamerDataProvider: SubscriptionDelegate {
    let pricesPublisher = PassthroughSubject<MarketPrice, Never>()
    
    private var client: LightstreamerClientProtocol?
    private var subscriptionConfig: LSSubscriptionConfiguration?
    private var subscription: LSSubscription?

    func instantiate(configuration: LSConfiguration) {
        self.client = lightstreamerClient(serverAddress: configuration.clientConfig.endpoint,
                                          adapterSet: configuration.clientConfig.adapterSet)
        self.subscriptionConfig = configuration.subscriptionConfig
    }

    func lightstreamerClient(serverAddress: String, adapterSet: String) -> LightstreamerClientProtocol {
        LightstreamerClient(serverAddress: serverAddress,
                            adapterSet: adapterSet)
    }

    func connect() {
        client?.connect()
    }

    func subscribe() {
        guard let client,
            let mode = subscriptionConfig?.mode,
            let items = subscriptionConfig?.items,
            let fields = subscriptionConfig?.fields else {
            return
        }
        if subscription == nil {
            subscription = Subscription(subscriptionMode: mode,
                                        items: items,
                                        fields: fields)
            subscription?.dataAdapter = subscriptionConfig?.dataAdapter
            subscription?.requestedSnapshot = subscriptionConfig?.requestedSnapshot
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

    // MARK: SubscriptionDelegate

    func subscription(_ subscription: LSSubscription,
                      didUpdateItem itemUpdate: ItemUpdate) {
        guard let stockName = itemUpdate.value(withFieldName: Fields.stockName.rawValue),
              let lastPrice = itemUpdate.value(withFieldName: Fields.lastPrice.rawValue) else {
            return
        }
        
        let priceUpdate = MarketPrice(
            stockName: stockName,
            lastPrice: lastPrice
        )
        
        Task { @MainActor in
            self.pricesPublisher.send(priceUpdate)
        }
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
