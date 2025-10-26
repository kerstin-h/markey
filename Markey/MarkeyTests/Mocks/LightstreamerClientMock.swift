//
//  LightstreamerClientMock.swift
//  Markey
//
//  Created by Kerstin Haustein on 12/09/2025.
//

import LightstreamerClient
@testable import Markey

final class LightstreamerClientMock: LightstreamerClientProtocol {
    
    let adapterSet: String
    let serverAddress: String

    var connected = false

    init(serverAddress: String = "", adapterSet: String = "") {
        self.adapterSet = adapterSet
        self.serverAddress = serverAddress
    }

    func connect() {
        connected = true
    }
    
    func disconnect() {
        connected = false
    }

    func subscribe(_ subscription: Markey.LSSubscription) {}

    func unsubscribe(_ subscription: Markey.LSSubscription) {}
}
