//
//  LightstreamerClientProtocol.swift
//  Markey
//
//  Created by Kerstin Haustein on 12/09/2025.
//
//  Lightstreamer docs:
//  https://github.com/Lightstreamer/Lightstreamer-lib-client-swift/tree/6.2.1
//

import LightstreamerClient

protocol LightstreamerClientProtocol: AnyObject {
    func connect()
    func disconnect()
    func subscribe(_ subscription: LSSubscription)
    func unsubscribe(_ subscription: LSSubscription)
}

extension LightstreamerClient: LightstreamerClientProtocol {}
