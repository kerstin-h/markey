//
//  MarketsListViewModelTests.swift
//  MarkeyTests
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import Testing
import Foundation
import Combine
@testable import Markey

final class MarketsListViewModelTests: Confirmation {
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: Test helpers
    
    private func viewModel(dataProvider: MarketStreamingDataProvider? = nil) -> MarketsListViewModel {
        let dataProvider = dataProvider ?? streamingDataProvider()
        return MarketsListViewModel(streamingDataProvider: dataProvider)
    }

    private func viewModel(streamerSubscription: DataStreamerSubscriptionMock) -> MarketsListViewModel {
        let dataProvider = streamingDataProvider(streamerSubscription: streamerSubscription)
        return MarketsListViewModel(streamingDataProvider: dataProvider)
    }
    
    private func streamingDataProvider(streamerSubscription: DataStreamerSubscriptionMock = DataStreamerSubscriptionMock()) -> MarketStreamingDataProvider {
        let streamingService = DataStreamingServiceMock(streamerSubscription: streamerSubscription)
        return MarketStreamingDataProvider(streamingService: streamingService)
    }
    
    // MARK: Tests

    @Test func startStreamingBeginsPriceUpdates() async throws {
        let marketPriceUpdate = MarketPrice.mock(stockName: "Nintendo", lastPrice: "100", changePercent: "10")
        let streamerSubscription = DataStreamerSubscriptionMock()
        let viewModel = viewModel(streamerSubscription: streamerSubscription)
        let confirmation = confirmation(comment: "The price update is successfully published")
        
        #expect(viewModel.marketList.count == 0)
        viewModel.startStreaming()
        viewModel.$markets.dropFirst().receive(on: DispatchQueue.main).sink(receiveValue: { marketPrice in
            confirmation.fulfill()
        }).store(in: &self.subscriptions)
        streamerSubscription.publish(marketPriceUpdate)
        await completion(confirmation: confirmation)
        
        try #require(viewModel.marketList.count == 1)
        #expect(viewModel.marketList[0].stockName == "Nintendo")
        #expect(viewModel.marketList[0].lastPrice == "100")
        #expect(viewModel.marketList[0].changePercent == "10")
    }
    
    @Test func marketsSortedAlphabetically() async throws {}
    
    @Test func startStreamingSubscribesOnceOnly() async throws {}
}
