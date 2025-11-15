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
    private let lightstreamerClient = LightstreamerClientMock()
    private let service: DataStreamingService

    init() {
        service = DataStreamingService(client: lightstreamerClient, subscriptionBuilder: SubscriptionBuilderMock())
    }

    // MARK: test helpers

    private func validateServiceSubscribedAndConnected(_ connected: Bool,
                                               client: LightstreamerClientMock?,
                                               subscription: DataStreamerSubscriptionMock?,
                                               comment: Comment) async {
        let serviceConnectedStatus = await service.connected
        #expect(serviceConnectedStatus == connected, comment)
        #expect(subscription?.subscribed == connected, comment)
        #expect(client?.connected == connected, comment)
    }

    // MARK: tests

    @Test("Test start stop streaming",
          .tags(.streaming)
    )
    func startStopStreaming() async {
        let subscription = await service.newSubscription()
        let subscriptionMock = subscription as? DataStreamerSubscriptionMock
        let clientMock = await service.client as? LightstreamerClientMock

        await validateServiceSubscribedAndConnected(false,
                                                    client: clientMock,
                                                    subscription: subscriptionMock,
                                                    comment: "Client should not be connected")

        await service.startStreaming(subscription: subscription)

        await validateServiceSubscribedAndConnected(true,
                                                    client: clientMock,
                                                    subscription: subscriptionMock,
                                                    comment: "Start streaming should connect client")

        await service.stopStreaming(subscription: subscription)

        await validateServiceSubscribedAndConnected(false,
                                                    client: clientMock,
                                                    subscription: subscriptionMock,
                                                    comment: "Stop streaming should disconnect client")

        await service.startStreaming(subscription: subscription)

        await validateServiceSubscribedAndConnected(true,
                                                    client: clientMock,
                                                    subscription: subscriptionMock,
                                                    comment: "Start streaming should connect client")
    }
}

final class SubscriptionBuilderMock: SubscriptionBuilderProtocol {
    func newSubscription(client: any Markey.LightstreamerClientProtocol) -> any DataStreamerSubscriptionProtocol {
        DataStreamerSubscriptionMock()
    }
}
