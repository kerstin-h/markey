//
//  LSCredentials.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

final class LSCredentials {
    var endpoint: String
    
    init(endpoint: String = "https://push.lightstreamer.com/") {
        self.endpoint = endpoint
    }
}
