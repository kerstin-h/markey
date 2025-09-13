//
//  DataStreamingServiceMock.swift
//  Markey
//
//  Created by Kerstin Haustein on 13/09/2025.
//

@testable import Markey

final class DataStreamingServiceMock: DataStreamingServiceProtocol {
    private let streamerSubscription: DataStreamerSubscriptionMock
    
    init(streamerSubscription: DataStreamerSubscriptionMock) {
        self.streamerSubscription = streamerSubscription
    }
    
    func newSubscription() -> any Markey.DataStreamerSubscriptionProtocol {
        streamerSubscription
    }
    
    func startStreaming(subscription: any Markey.DataStreamerSubscriptionProtocol) {}
}
