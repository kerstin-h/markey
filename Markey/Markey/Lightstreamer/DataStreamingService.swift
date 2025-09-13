//
//  DataStreamingService.swift
//  Markey
//
//  Created by Kerstin Haustein on 13/09/2025.
//

protocol DataStreamingServiceProtocol {
    func newSubscription() -> DataStreamerSubscriptionProtocol
    func startStreaming(subscription: DataStreamerSubscriptionProtocol)
}

final class DataStreamingService: DataStreamingServiceProtocol {
    
    private let client: LightstreamerClientProtocol
    private var connected = false
    
    init(client: LightstreamerClientProtocol) {
        self.client = client
    }
    
    private func connectIfNeeded() {
        if !connected {
            client.connect()
        }
    }
    
    private func disconnectIfNeeded() {
        if connected {
            client.disconnect()
        }
    }

    func newSubscription() -> DataStreamerSubscriptionProtocol {
        let config = LSSubscriptionConfiguration()
        let subscription = LSSubscription(subscriptionMode: config.mode,
                                        items: config.items,
                                        fields: config.fields)
        subscription.dataAdapter = config.dataAdapter
        subscription.requestedSnapshot = config.requestedSnapshot
        return DataStreamerSubscription(client: client,
                                         subscription: subscription)
    }

    func startStreaming(subscription: DataStreamerSubscriptionProtocol) {
        connectIfNeeded()
        subscription.subscribe()
    }

    func stopStreaming(subscription: DataStreamerSubscription) {
        disconnectIfNeeded()
        subscription.unsubscribe()
    }
}

