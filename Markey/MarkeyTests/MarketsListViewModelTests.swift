//
//  MarketsListViewModelTests.swift
//  MarkeyTests
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import Testing
import Combine
@testable import Markey

final class MarketsListViewModelTests {
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: Test helpers
    
    private func viewModel(dataProvider: MarketStreamingDataProvider? = nil) -> MarketsListViewModel {
        let dataProvider = dataProvider ?? streamingDataProvider()
        return MarketsListViewModel(streamingDataProvider: dataProvider)
    }
    
    private func streamingDataProvider(streamerSubscription: DataStreamerSubscriptionMock = DataStreamerSubscriptionMock()) -> MarketStreamingDataProvider {
        let streamingService = DataStreamingServiceMock(streamerSubscription: streamerSubscription)
        return MarketStreamingDataProvider(streamingService: streamingService)
    }
    
    // MARK: Tests

    @Test func startStreamingBeginsUpdates() async throws {
        let marketPriceUpdate = MarketPrice.mock(stockName: "Nintendo", lastPrice: "100", changePercent: "10")
        let streamerSubscription = DataStreamerSubscriptionMock()
        let dataProvider = streamingDataProvider(streamerSubscription: streamerSubscription)
        let viewModel = viewModel(dataProvider: dataProvider)
        
        await confirmation(expectedCount: 1) { confirm in
            #expect(viewModel.marketList.count == 0)
            viewModel.$markets.sink(receiveValue: { marketPrice in
                if marketPrice.keys.count > 1 {
                    confirm()
                }
            }).store(in: &subscriptions)
            streamerSubscription.publish(marketPriceUpdate)
        }
        
        #expect(viewModel.marketList.count == 1)
        #expect(viewModel.marketList.first?.stockName == "Nintendo")
        #expect(viewModel.marketList.first?.lastPrice == "100")
        #expect(viewModel.marketList.first?.changePercent == "10")
    }
    
    @Test func marketsSortedAlphabetically() async throws {}
    
    @Test func startStreamingSubscribesOnceOnly() async throws {}
}

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
