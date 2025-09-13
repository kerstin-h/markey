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

    init(serverAddress: String, adapterSet: String) {
        self.adapterSet = adapterSet
        self.serverAddress = serverAddress
    }

    func connect() {}
    
    func disconnect() {}
    
    func subscribe(_ subscription: LSSubscription) {}
    
    func unsubscribe(_ subscription: LSSubscription) {}

    func subscription(_ subscription: LSSubscription,
                      didUpdateItem itemUpdate: ItemUpdate) {}
}
