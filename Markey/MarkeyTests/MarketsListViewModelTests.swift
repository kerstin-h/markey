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
    private let viewModel: MarketsListViewModel
    private let streamerSubscription = DataStreamerSubscriptionMock()
    private var subscriptions = Set<AnyCancellable>()
    
    var confirm: Confirm?

    init() {
        viewModel = Self.viewModel(with: streamerSubscription)
    }

    // MARK: Test helpers

    private static func viewModel(with streamerSubscription: DataStreamerSubscriptionMock) -> MarketsListViewModel {
        let streamingService = DataStreamingServiceMock(streamerSubscription: streamerSubscription)
        let dataProvider = MarketStreamingDataProvider(streamingService: streamingService)
        return MarketsListViewModel(streamingDataProvider: dataProvider)
    }

    private func sendStreamingUpdate(marketPrices: [MarketPrice]) async {
        confirm = newConfirm()
        subscriptions.removeAll()
        await confirmation(expectedCount: marketPrices.count) {
            self.viewModel.$markets.dropFirst().receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] marketPrice in
                self?.confirm()
            }).store(in: &self.subscriptions)
            for index in 0..<marketPrices.count {
                self.streamerSubscription.publish(marketPrices[index])
            }
        }
    }

    // MARK: Tests

    @Test("Start streaming begins price updates",
          .tags(.streamingUpdates))
    func startStreamingBeginsUpdates() async throws {
        let marketPriceUpdate = MarketPrice(stockName: "Nintendo", lastPrice: "100", changePercent: "10")
        
        #expect(viewModel.marketList.count == 0)
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: [marketPriceUpdate])

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
        
        #expect(viewModel.marketList.count == 0)
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: marketPriceUpdates)

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

        #expect(viewModel.marketList.count == 0)
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: marketPrices)

        try #require(viewModel.marketList.count == 3)
        #expect(viewModel.marketList[0] == MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"))
        #expect(viewModel.marketList[1] == MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"))
        #expect(viewModel.marketList[2] == MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"))

        await sendStreamingUpdate(marketPrices: [marketPriceUpdate])

        try #require(viewModel.marketList.count == 4)
        #expect(viewModel.marketList[0] == MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"))
        #expect(viewModel.marketList[1] == MarketPrice(stockName: "Key", lastPrice: "13", changePercent: "-1"))
        #expect(viewModel.marketList[2] == MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"))
        #expect(viewModel.marketList[3] == MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"))
    }

    struct PriceUpdates {
        let marketPrices: [MarketPrice]
        let sortedMarketPrices: [MarketPrice]
    }

    @Test("Markets prices update correctly on update",
          .tags(.streamingUpdates),
          arguments: [
            PriceUpdates(
                marketPrices: [
                    MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "50")
                ],
                sortedMarketPrices: [
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "50")
                ]),
            PriceUpdates(
                marketPrices: [
                    MarketPrice(stockName: "Mushroom", lastPrice: "888", changePercent: "1"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"),
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "50"),
                    MarketPrice(stockName: "Key", lastPrice: "13", changePercent: "-1")
                ],
                sortedMarketPrices: [
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "50"),
                    MarketPrice(stockName: "Key", lastPrice: "13", changePercent: "-1"),
                    MarketPrice(stockName: "Mushroom", lastPrice: "888", changePercent: "1"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5")
                ]
            )
          ])
    func marketPricesUpdateCorrectlyForMarket(priceUpdates: PriceUpdates) async throws {
        let marketPrices = [
            MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
            MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"),
            MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10")
        ]

        #expect(viewModel.marketList.count == 0)
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: marketPrices)

        try #require(viewModel.marketList.count == 3)
        #expect(viewModel.marketList[0] == MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"))
        #expect(viewModel.marketList[1] == MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"))
        #expect(viewModel.marketList[2] == MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"))

        await sendStreamingUpdate(marketPrices: priceUpdates.marketPrices)

        try #require(viewModel.marketList.count == priceUpdates.marketPrices.count)
        for index in 0..<priceUpdates.marketPrices.count {
            #expect(viewModel.marketList[index] == priceUpdates.sortedMarketPrices[index])
        }
    }

    @Test("Stop streaming behaves correctly",
          .tags(.streamingUpdates))
    func stopStreaming() async throws {}
}
