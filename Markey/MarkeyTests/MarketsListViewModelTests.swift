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

    struct TestData<DataType> {
        let inputData: DataType
        let expectedResult: DataType
    }

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
          .tags(.streamingUpdates),
          arguments: [
            TestData(
                inputData: MarketPrice(stockName: "Nintendo", lastPrice: "100", changePercent: "10"),
                expectedResult: MarketPrice(stockName: "Nintendo", lastPrice: "100", changePercent: "10")
            )
          ])
    func startStreamingBeginsUpdates(for priceUpdate: TestData<MarketPrice>) async throws {
        #expect(viewModel.marketList.count == 0)
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: [priceUpdate.inputData])

        let firstMarket = try #require(viewModel.marketList.first)
        #expect(firstMarket == priceUpdate.expectedResult)
    }

    @Test("Markets display alphabetically",
          .tags(.sorting, .streamingUpdates),
          arguments: [
            TestData(
                inputData: [
                    MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"),
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10")
                ],
                expectedResult: [
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5")
                ])
          ])
    func marketsSortedAlphabetically(for priceUpdates: TestData<[MarketPrice]>) async throws {
        #expect(viewModel.marketList.count == 0)
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: priceUpdates.inputData)

        try #require(viewModel.marketList.count == priceUpdates.expectedResult.count)
        #expect(viewModel.marketList == priceUpdates.expectedResult)
    }
    
    @Test("Markets display alphabetically after multiple updates",
          .tags(.sorting, .streamingUpdates),
          arguments: [[
            TestData( // first update
                inputData: [
                    MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"),
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10")
                ],
                expectedResult: [
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5")
                ]),
            TestData( // second update
                inputData: [
                    MarketPrice(stockName: "Key", lastPrice: "13", changePercent: "-1")
                ],
                expectedResult: [
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketPrice(stockName: "Key", lastPrice: "13", changePercent: "-1"),
                    MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5")
                ])
          ]]
    )
    func marketUpdatesSortedAlphabetically(for multiplePriceUpdates: [TestData<[MarketPrice]>]) async throws {
        #expect(viewModel.marketList.count == 0)
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: multiplePriceUpdates[0].inputData)

        try #require(viewModel.marketList.count == multiplePriceUpdates[0].expectedResult.count)
        #expect(viewModel.marketList == multiplePriceUpdates[0].expectedResult)

        await sendStreamingUpdate(marketPrices: multiplePriceUpdates[1].inputData)

        try #require(viewModel.marketList.count == multiplePriceUpdates[1].expectedResult.count)
        #expect(viewModel.marketList == multiplePriceUpdates[1].expectedResult)
    }

    @Test("Markets prices update values correctly on update",
          .tags(.streamingUpdates),
          arguments: [
            TestData( // first test scenario
                inputData: [
                    MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "50")
                ],
                expectedResult: [
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "50")
                ]),
            TestData( // second test scenario
                inputData: [
                    MarketPrice(stockName: "Mushroom", lastPrice: "888", changePercent: "1"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"),
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "50"),
                    MarketPrice(stockName: "Key", lastPrice: "13", changePercent: "-1")
                ],
                expectedResult: [
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "50"),
                    MarketPrice(stockName: "Key", lastPrice: "13", changePercent: "-1"),
                    MarketPrice(stockName: "Mushroom", lastPrice: "888", changePercent: "1"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5")
                ]
            )
          ])
    func marketPricesUpdateCorrectlyForMarket(priceUpdates: TestData<[MarketPrice]>) async throws {
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

        await sendStreamingUpdate(marketPrices: priceUpdates.inputData)

        try #require(viewModel.marketList.count == priceUpdates.expectedResult.count)
        #expect(viewModel.marketList == priceUpdates.expectedResult)
    }

    @Test("Stop streaming behaves correctly",
          .tags(.streamingUpdates))
    func stopStreaming() async throws {}
}
