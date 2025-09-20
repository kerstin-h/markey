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
    
    lazy var confirm: Confirm = {
        newConfirm()
    }()
    
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

    @Test("Start streaming begins price updates") func startStreaming() async throws {
        let marketPriceUpdate = MarketPrice.mock(stockName: "Nintendo", lastPrice: "100", changePercent: "10")
        let streamerSubscription = DataStreamerSubscriptionMock()
        let viewModel = viewModel(streamerSubscription: streamerSubscription)
        
        #expect(viewModel.marketList.count == 0)
        viewModel.startStreaming()
        await confirmation {
            viewModel.$markets.dropFirst().receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] marketPrice in
                self?.confirm()
            }).store(in: &self.subscriptions)
            streamerSubscription.publish(marketPriceUpdate)
        }
        
        let firstMarket = try #require(viewModel.marketList.first)
        #expect(firstMarket.stockName == "Nintendo")
        #expect(firstMarket.lastPrice == "100")
        #expect(firstMarket.changePercent == "10")
    }
    
    @Test func marketsSortedAlphabetically() async throws {}
    
    @Test func startStreamingSubscribesOnceOnly() async throws {}
}
