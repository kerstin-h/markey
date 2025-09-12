//
//  LSConfiguration.swift
//  Markey
//
//  Created by Kerstin Haustein on 12/09/2025.
//

struct LSConfiguration {
    let clientConfig: LSClientConfiguration
    let subscriptionConfig: LSSubscriptionConfiguration
    
    init(clientConfig: LSClientConfiguration = LSClientConfiguration(),
         subscriptionConfig: LSSubscriptionConfiguration = LSSubscriptionConfiguration()) {
        self.clientConfig = clientConfig
        self.subscriptionConfig = subscriptionConfig
    }
}
