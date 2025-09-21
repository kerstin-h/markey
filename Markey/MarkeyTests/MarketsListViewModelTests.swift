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

extension Tag {
    @Tag static var marketList: Self
    @Tag static var sorting: Self
    @Tag static var streamingUpdates: Self
}

@Suite("Market List",
       .tags(.marketList))
final class MarketsListViewModelTests: Confirmation {
    private var subscriptions = Set<AnyCancellable>()
    
    var confirm: Confirm?

    // MARK: Test helpers

    private func viewModel(streamerSubscription: DataStreamerSubscriptionMock) -> MarketsListViewModel {
        let dataProvider = streamingDataProvider(streamerSubscription: streamerSubscription)
        return MarketsListViewModel(streamingDataProvider: dataProvider)
    }
    
    private func streamingDataProvider(streamerSubscription: DataStreamerSubscriptionMock = DataStreamerSubscriptionMock()) -> MarketStreamingDataProvider {
        let streamingService = DataStreamingServiceMock(streamerSubscription: streamerSubscription)
        return MarketStreamingDataProvider(streamingService: streamingService)
    }
    
    private func viewModelWithStreamingUpdates(_ marketPrices: [MarketPrice]) async -> MarketsListViewModel {
        let streamerSubscription = DataStreamerSubscriptionMock()
        let viewModel = viewModel(streamerSubscription: streamerSubscription)

        #expect(viewModel.marketList.count == 0)
        viewModel.startStreaming()
        await sendStreamingUpdate(viewModel: viewModel,
                                  streamerSubscription: streamerSubscription,
                                  marketPrices: marketPrices)
        return viewModel
    }

    private func sendStreamingUpdate(viewModel: MarketsListViewModel,
                                     streamerSubscription: DataStreamerSubscriptionMock,
                                     marketPrices: [MarketPrice]) async {
        confirm = newConfirm()
        subscriptions.removeAll()
        await confirmation(expectedCount: marketPrices.count) {
            viewModel.$markets.dropFirst().receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] marketPrice in
                self?.confirm()
            }).store(in: &self.subscriptions)
            for index in 0..<marketPrices.count {
                streamerSubscription.publish(marketPrices[index])
            }
        }
    }

    // MARK: Tests

    @Test("Start streaming begins price updates",
          .tags(.streamingUpdates))
    func startStreamingBeginsUpdates() async throws {
        let marketPriceUpdate = MarketPrice(stockName: "Nintendo", lastPrice: "100", changePercent: "10")
        
        let viewModel = await viewModelWithStreamingUpdates([marketPriceUpdate])
        
        let firstMarket = try #require(viewModel.marketList.first)
        #expect(firstMarket.stockName == "Nintendo")
        #expect(firstMarket.lastPrice == "100")
        #expect(firstMarket.changePercent == "10")
    }

    @Test("Markets display alphabetically",
          .tags(.sorting, .streamingUpdates))
    func marketsSortedAlphabetically() async throws {
        let marketPriceUpdates = [
            MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
            MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"),
            MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10")
        ]
        
        let viewModel = await viewModelWithStreamingUpdates(marketPriceUpdates)
        
        try #require(viewModel.marketList.count == 3)
        #expect(viewModel.marketList[0] == MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"))
        #expect(viewModel.marketList[1] == MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"))
        #expect(viewModel.marketList[2] == MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"))
    }
    
    @Test("Markets display alphabetically after list updates",
          .tags(.sorting, .streamingUpdates))
    func marketUpdatesSortedAlphabetically() async throws {
        let marketPrices = [
            MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
            MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"),
            MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10")
        ]
        let marketPriceUpdate = MarketPrice(stockName: "Key", lastPrice: "13", changePercent: "-1")
        let streamerSubscription = DataStreamerSubscriptionMock()
        let viewModel = viewModel(streamerSubscription: streamerSubscription)

        #expect(viewModel.marketList.count == 0)
        viewModel.startStreaming()
        await sendStreamingUpdate(viewModel: viewModel,
                                  streamerSubscription: streamerSubscription,
                                  marketPrices: marketPrices)

        try #require(viewModel.marketList.count == 3)
        #expect(viewModel.marketList[0] == MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"))
        #expect(viewModel.marketList[1] == MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"))
        #expect(viewModel.marketList[2] == MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"))

        await sendStreamingUpdate(viewModel: viewModel,
                                  streamerSubscription: streamerSubscription,
                                  marketPrices: [marketPriceUpdate])

        try #require(viewModel.marketList.count == 4)
        #expect(viewModel.marketList[0] == MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"))
        #expect(viewModel.marketList[1] == MarketPrice(stockName: "Key", lastPrice: "13", changePercent: "-1"))
        #expect(viewModel.marketList[2] == MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"))
        #expect(viewModel.marketList[3] == MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"))
    }

    @Test("Markets prices update correctly",
          .tags(.streamingUpdates))
    func marketPricesUpdateCorrectlyForMarket() async throws {}

    @Test("Stop streaming behaves correctly",
          .tags(.streamingUpdates))
    func stopStreaming() async throws {}
}
