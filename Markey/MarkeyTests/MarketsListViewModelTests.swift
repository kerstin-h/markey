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

    private func sendStreamingUpdate(marketPrices: [MarketPrice],
                                     expectSuccessful: Bool = true) async {
        subscriptions.removeAll()
        confirm = newConfirm(isInverted: !expectSuccessful)
        await confirmation(expectedCount: marketPrices.count) {
            self.viewModel.$markets.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] markets in
                if marketPrices.contains(where: { markets.values.contains($0) }) {
                    self?.confirm()
                }
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
                expectedResult: MarketPrice(stockName: "Nintendo", lastPrice: "100", changePercent: "10"),
                description: "Price update"
            )
          ])
    func startStreamingBeginsUpdates(for priceUpdate: TestData<MarketPrice>) async throws {
        #expect(viewModel.marketList.count == 0,
                "Market list should be empty")
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: [priceUpdate.inputData])

        let firstMarket = try #require(viewModel.marketList.first)
        #expect(firstMarket == priceUpdate.expectedResult,
                "Market list should display \(priceUpdate.description) after streaming is started")
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
                ],
                description: "Market updates"
            )
          ])
    func marketsSortedAlphabetically(for priceUpdates: TestData<[MarketPrice]>) async throws {
        #expect(viewModel.marketList.count == 0,
                "Market list should be empty")
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: priceUpdates.inputData)

        try #require(viewModel.marketList.count == priceUpdates.expectedResult.count)
        #expect(viewModel.marketList == priceUpdates.expectedResult,
                "Market list should display \(priceUpdates.description) alphabetically")
    }
    
    @Test("Markets display alphabetically after multiple updates",
          .tags(.sorting, .streamingUpdates),
          arguments: [[
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
                ],
                description: "Update #1"
            ),
            TestData(
                inputData: [
                    MarketPrice(stockName: "Key", lastPrice: "13", changePercent: "-1")
                ],
                expectedResult: [
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketPrice(stockName: "Key", lastPrice: "13", changePercent: "-1"),
                    MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5")
                ],
                description: "Update #2"
            )
          ]]
    )
    func marketUpdatesSortedAlphabetically(for priceUpdates: [TestData<[MarketPrice]>]) async throws {
        #expect(viewModel.marketList.count == 0,
                "Market list should be empty")
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: priceUpdates[0].inputData)

        try #require(viewModel.marketList.count == priceUpdates[0].expectedResult.count)
        #expect(viewModel.marketList == priceUpdates[0].expectedResult,
                "Market list should display \(priceUpdates[0].description) alphabetically")

        await sendStreamingUpdate(marketPrices: priceUpdates[1].inputData)

        try #require(viewModel.marketList.count == priceUpdates[1].expectedResult.count)
        #expect(viewModel.marketList == priceUpdates[1].expectedResult,
                "Market list should display \(priceUpdates[1].description) alphabetically with new markets added")
    }

    @Test("Markets prices update values correctly on update",
          .tags(.streamingUpdates),
          arguments: [
            TestData(
                inputData: [
                    MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "50")
                ],
                expectedResult: [
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "50")
                ],
                description: "Test scenario #1"
            ),
            TestData(
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
                ],
                description: "Test scenario #2"
            )
          ])
    func marketPricesUpdateCorrectlyForMarket(for priceUpdates: TestData<[MarketPrice]>) async throws {
        let marketPrices = [
            MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
            MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"),
            MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10")
        ]

        #expect(viewModel.marketList.count == 0,
                "Market list should be empty")
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: marketPrices)

        try #require(viewModel.marketList.count == 3)
        #expect(viewModel.marketList[0] == MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                "Market list should display initial update alphabetically - flower field first")
        #expect(viewModel.marketList[1] == MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                "Market list should display initial update alphabetically - mushroom field second")
        #expect(viewModel.marketList[2] == MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"),
                "Market list should display initial update alphabetically - star field third")

        await sendStreamingUpdate(marketPrices: priceUpdates.inputData)

        try #require(viewModel.marketList.count == priceUpdates.expectedResult.count)
        #expect(viewModel.marketList == priceUpdates.expectedResult,
                "Market list should display second update alphabetically with correctly updated prices and new markets added where applicable for \(priceUpdates.description)")
    }

    @Test("Stop streaming behaves correctly",
          .tags(.streamingUpdates),
          arguments: [[
            TestData(
                inputData: [MarketPrice.mock(stockName: "Nintendo")],
                expectedResult: [MarketPrice.mock(stockName: "Nintendo")],
                description: "Update #1"
            ),
            TestData(
                inputData: [MarketPrice.mock(stockName: "Sega")],
                expectedResult: [MarketPrice.mock(stockName: "Nintendo")],
                description: "Update #2"
            )
          ]])
    func stopStreaming(for priceUpdates: [TestData<[MarketPrice]>]) async throws {
        #expect(viewModel.marketList.count == 0,
                "Market list should be empty")
        viewModel.startStreaming()

        await sendStreamingUpdate(marketPrices: priceUpdates[0].inputData)

        try #require(viewModel.marketList.count == priceUpdates[0].expectedResult.count)
        #expect(viewModel.marketList == priceUpdates[0].expectedResult,
                "Market list should display \(priceUpdates[0].description) after starting streaming")

        viewModel.stopStreaming()
        await sendStreamingUpdate(marketPrices: priceUpdates[1].inputData, expectSuccessful: false)

        try #require(viewModel.marketList.count == priceUpdates[1].expectedResult.count)
        #expect(viewModel.marketList == priceUpdates[1].expectedResult,
                "Market list should ignore \(priceUpdates[1].description) after starting streaming")
    }

    @Test("Test stop start streaming behaves correctly",
          .tags(.streamingUpdates),
          arguments: [[
            TestData(
                inputData: [MarketPrice.mock(stockName: "Nintendo")],
                expectedResult: [MarketPrice.mock(stockName: "Nintendo")],
                description: "Update #1"
            ),
            TestData(
                inputData: [MarketPrice.mock(stockName: "Sega")],
                expectedResult: [MarketPrice.mock(stockName: "Nintendo")],
                description: "Update #2"
            ),
            TestData(
                inputData: [MarketPrice.mock(stockName: "XBox")],
                expectedResult: [MarketPrice.mock(stockName: "Nintendo"),
                                 MarketPrice.mock(stockName: "XBox")],
                description: "Update #3"
            )
          ]])
    func stopStartStreaming(for priceUpdates: [TestData<[MarketPrice]>]) async throws {
        #expect(viewModel.marketList.count == 0,
                "Market list should be empty")
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: priceUpdates[0].inputData)

        try #require(viewModel.marketList.count == priceUpdates[0].expectedResult.count)
        #expect(viewModel.marketList == priceUpdates[0].expectedResult,
                "Market list should display \(priceUpdates[0].description) after starting streaming")

        viewModel.stopStreaming()
        await sendStreamingUpdate(marketPrices: priceUpdates[1].inputData, expectSuccessful: false)

        try #require(viewModel.marketList.count == priceUpdates[1].expectedResult.count)
        #expect(viewModel.marketList == priceUpdates[1].expectedResult,
                "Market list should ignore \(priceUpdates[1].description) after stopping streaming")

        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: priceUpdates[2].inputData)

        try #require(viewModel.marketList.count == priceUpdates[2].expectedResult.count)
        #expect(viewModel.marketList == priceUpdates[2].expectedResult,
                "Market list should display \(priceUpdates[2].description) after starting streaming again")
    }
}
