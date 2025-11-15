//
//  DataStreamingService.swift
//  Markey
//
//  Created by Kerstin Haustein on 13/09/2025.
//

protocol DataStreamingServiceProtocol: Actor {
    func newSubscription() -> DataStreamerSubscriptionProtocol
    func startStreaming(subscription: DataStreamerSubscriptionProtocol) async
}

actor DataStreamingService: DataStreamingServiceProtocol {
    let client: LightstreamerClientProtocol
    let subscriptionBuilder: SubscriptionBuilderProtocol
    var connected = false
    
    init(client: LightstreamerClientProtocol,
         subscriptionBuilder: SubscriptionBuilderProtocol = SubscriptionBuilder()) {
        self.client = client
        self.subscriptionBuilder = subscriptionBuilder
    }
    
    private func connectIfNeeded() {
        if !connected {
            client.connect()
            connected = true
        }
    }
    
    private func disconnectIfNeeded() {
        if connected {
            client.disconnect()
            connected = false
        }
    }

    func newSubscription() -> DataStreamerSubscriptionProtocol {
        subscriptionBuilder.newSubscription(client: client)
    }

    func startStreaming(subscription: DataStreamerSubscriptionProtocol) async {
        connectIfNeeded()
        await subscription.subscribe()
    }

    func stopStreaming(subscription: DataStreamerSubscriptionProtocol) async {
        disconnectIfNeeded()
        await subscription.unsubscribe()
    }
}
