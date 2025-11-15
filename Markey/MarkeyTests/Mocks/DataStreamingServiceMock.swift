//
//  DataStreamingServiceMock.swift
//  Markey
//
//  Created by Kerstin Haustein on 13/09/2025.
//

@testable import Markey

struct StreamingConfirm: ConfirmationHandler {
    var confirm: (any Confirm)?

    init() {
        confirm = newConfirm(comment: "Streaming started", isInverted: false)
    }
}

actor DataStreamingServiceMock: DataStreamingServiceProtocol {
    let streamingConfirmation = StreamingConfirm()

    private let streamerSubscription: DataStreamerSubscriptionMock
    
    init(streamerSubscription: DataStreamerSubscriptionMock) {
        self.streamerSubscription = streamerSubscription
    }
    
    func newSubscription() -> any Markey.DataStreamerSubscriptionProtocol {
        streamerSubscription
    }
    
    func startStreaming(subscription: any Markey.DataStreamerSubscriptionProtocol) {
        streamingConfirmation.confirm()
    }
}
