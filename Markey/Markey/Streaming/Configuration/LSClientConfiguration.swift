//
//  LSClientConfiguration.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

struct LSClientConfiguration {
    let adapterSet: String
    let endpoint: String
    
    init(adapterSet: String = "DEMO",
         endpoint: String = "https://push.lightstreamer.com/") {
        self.adapterSet = adapterSet
        self.endpoint = endpoint
    }
}
