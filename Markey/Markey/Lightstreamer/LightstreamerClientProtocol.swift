//
//  LightstreamerClientProtocol.swift
//  Markey
//
//  Created by Kerstin Haustein on 12/09/2025.
//

import LightstreamerClient

protocol LightstreamerClientProtocol {
    func connect()
    func disconnect()
    func subscribe(_ subscription: LSSubscription)
    func unsubscribe(_ subscription: LSSubscription)
}

extension LightstreamerClient: LightstreamerClientProtocol {}
