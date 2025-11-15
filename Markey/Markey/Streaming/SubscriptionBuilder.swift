//
//  SubscriptionBuilder.swift
//  Markey
//
//  Created by Kerstin Haustein on 15/11/2025.
//

protocol SubscriptionBuilderProtocol {
    func newSubscription(client: LightstreamerClientProtocol) -> DataStreamerSubscriptionProtocol
}

final class SubscriptionBuilder: SubscriptionBuilderProtocol {
    func newSubscription(client: LightstreamerClientProtocol) -> DataStreamerSubscriptionProtocol {
        let config = LSSubscriptionConfiguration()
        let subscription = LSSubscription(subscriptionMode: config.mode,
                                          items: config.items,
                                          fields: config.fields)
        subscription.dataAdapter = config.dataAdapter
        subscription.requestedSnapshot = config.requestedSnapshot
        return DataStreamerSubscription(client: client,
                                        subscription: subscription)
    }
}
