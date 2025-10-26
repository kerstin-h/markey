//
//  DataStreamingServiceTests.swift
//  Markey
//
//  Created by Kerstin Haustein on 26/10/2025.
//

import Testing
@testable import Markey

extension Tag {
    @Tag static var streaming: Self
}

struct DataStreamingServiceTests {
    let lightstreamerClient = LightstreamerClientMock()

    // MARK: test helpers

    private class DataStreamingServiceFortTest: DataStreamingService {
        override func newSubscription() -> any DataStreamerSubscriptionProtocol {
            DataStreamerSubscriptionMock()
        }
    }

    private func dataStreamingService() -> DataStreamingService {
        DataStreamingServiceFortTest(client: lightstreamerClient)
    }

    // MARK: Tests

    @Test("Test start stop streaming",
          .tags(.streaming)
    )
    func startStopStreaming() {
        let service = dataStreamingService()
        #expect(service.connected == false)

        let clientMock = service.client as? LightstreamerClientMock
        #expect(clientMock?.connected == false)

        let subscription = service.newSubscription()
        let subscriptionMock = subscription as? DataStreamerSubscriptionMock
        #expect(subscriptionMock?.subscribed == false)

        service.startStreaming(subscription: subscription)
        #expect(service.connected == true, "Start streaming should connect client")
        #expect(subscriptionMock?.subscribed == true)
        #expect(clientMock?.connected == true)

        service.stopStreaming(subscription: subscription)
        #expect(service.connected == false, "Stop streaming should disconnect client")
        #expect(subscriptionMock?.subscribed == false)
        #expect(clientMock?.connected == false)

        service.startStreaming(subscription: subscription)
        #expect(service.connected == true, "Start streaming should connect client")
        #expect(subscriptionMock?.subscribed == true)
        #expect(clientMock?.connected == true)
    }
}


