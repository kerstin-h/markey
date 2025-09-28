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
            self.viewModel.$marketRowViewModels.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] marketsRows in
                if marketPrices.allSatisfy({ marketPrice in
                    marketsRows.contains(where: { $0.stockName == marketPrice.stockName} )
                }) {
                    self?.confirm()
                }
            }).store(in: &self.subscriptions)
            for index in 0..<marketPrices.count {
                self.streamerSubscription.publish(marketPrices[index])
            }
        }
    }

    private func sendStreamingError(_ error: StreamingError) async {
        subscriptions.removeAll()
        confirm = newConfirm(isInverted: false)
        await confirmation(expectedCount: 1) {
            self.viewModel.$marketRowViewModels
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.confirm()
                    }
                }, receiveValue: { _ in }
            ).store(in: &self.subscriptions)
            self.streamerSubscription.publish(error)
        }
    }

    // MARK: Tests

    @Test("Start streaming begins price updates",
          .tags(.streamingUpdates),
          arguments: [
            TestData(
                inputData: MarketPrice(stockName: "Nintendo", lastPrice: "100", changePercent: "10"),
                expectedResult: MarketRowViewModel(stockName: "Nintendo", lastPrice: "100", changePercent: "10"),
                description: "Market price update"
            )
          ])
    func startStreamingBeginsUpdates(for priceUpdate: TestData<MarketPrice, MarketRowViewModel>) async throws {
        #expect(viewModel.marketRowViewModels.count == 0,
                "Market list should be empty")
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: [priceUpdate.inputData])

        let firstMarket = try #require(viewModel.marketRowViewModels.first)
        #expect(firstMarket == priceUpdate.expectedResult,
                "Market list should display \(priceUpdate.description) after streaming is started")
    }

    @Test("Start streaming failure shows alert",
          .tags(.streamingUpdates))
    func startStreamingFailureShowsAlert() async throws {
        #expect(viewModel.showAlert == false,
                "Market list should not show alert by default")
        viewModel.startStreaming()
        await sendStreamingError(.subscriptionFailure(code: 1, message: nil))
        #expect(viewModel.showAlert == true,
                "Market list should show error alert on streaming failure")
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
                    MarketRowViewModel(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketRowViewModel(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketRowViewModel(stockName: "Star", lastPrice: "100", changePercent: "5")
                ],
                description: "Market price updates"
            )
          ])
    func marketsSortedAlphabetically(for priceUpdates: TestData<[MarketPrice], [MarketRowViewModel]>) async throws {
        #expect(viewModel.marketRowViewModels.count == 0,
                "Market list should be empty")
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: priceUpdates.inputData)

        try #require(viewModel.marketRowViewModels.count == priceUpdates.expectedResult.count)
        #expect(viewModel.marketRowViewModels == priceUpdates.expectedResult,
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
                    MarketRowViewModel(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketRowViewModel(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketRowViewModel(stockName: "Star", lastPrice: "100", changePercent: "5")
                ],
                description: "Update #1"
            ),
            TestData(
                inputData: [
                    MarketPrice(stockName: "Key", lastPrice: "13", changePercent: "-1")
                ],
                expectedResult: [
                    MarketRowViewModel(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketRowViewModel(stockName: "Key", lastPrice: "13", changePercent: "-1"),
                    MarketRowViewModel(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketRowViewModel(stockName: "Star", lastPrice: "100", changePercent: "5")
                ],
                description: "Update #2"
            )
          ]]
    )
    func marketUpdatesSortedAlphabetically(for priceUpdates: [TestData<[MarketPrice], [MarketRowViewModel]>]) async throws {
        #expect(viewModel.marketRowViewModels.count == 0,
                "Market list should be empty")
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: priceUpdates[0].inputData)

        try #require(viewModel.marketRowViewModels.count == priceUpdates[0].expectedResult.count)
        #expect(viewModel.marketRowViewModels == priceUpdates[0].expectedResult,
                "Market list should display \(priceUpdates[0].description) alphabetically")

        await sendStreamingUpdate(marketPrices: priceUpdates[1].inputData)

        try #require(viewModel.marketRowViewModels.count == priceUpdates[1].expectedResult.count)
        #expect(viewModel.marketRowViewModels == priceUpdates[1].expectedResult,
                "Market list should display \(priceUpdates[1].description) alphabetically with new markets added")
    }

    @Test("Markets prices update values correctly when receive update",
          .tags(.streamingUpdates),
          arguments: [
            TestData(
                inputData: [
                    MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "50")
                ],
                expectedResult: [
                    MarketRowViewModel(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                    MarketRowViewModel(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                    MarketRowViewModel(stockName: "Star", lastPrice: "100", changePercent: "50")
                ],
                description: "Test #1 - for same number of rows"
            ),
            TestData(
                inputData: [
                    MarketPrice(stockName: "Mushroom", lastPrice: "888", changePercent: "1"),
                    MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"),
                    MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "50"),
                    MarketPrice(stockName: "Key", lastPrice: "13", changePercent: "-1")
                ],
                expectedResult: [
                    MarketRowViewModel(stockName: "Flower", lastPrice: "134", changePercent: "50"),
                    MarketRowViewModel(stockName: "Key", lastPrice: "13", changePercent: "-1"),
                    MarketRowViewModel(stockName: "Mushroom", lastPrice: "888", changePercent: "1"),
                    MarketRowViewModel(stockName: "Star", lastPrice: "100", changePercent: "5")
                ],
                description: "Test #2 - for additional rows"
            )
          ])
    func marketPricesUpdateCorrectlyForMarket(for priceUpdates: TestData<[MarketPrice], [MarketRowViewModel]>) async throws {
        let marketPrices = [
            MarketPrice(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
            MarketPrice(stockName: "Star", lastPrice: "100", changePercent: "5"),
            MarketPrice(stockName: "Flower", lastPrice: "134", changePercent: "-10")
        ]

        #expect(viewModel.marketRowViewModels.count == 0,
                "Market list should be empty")
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: marketPrices)

        try #require(viewModel.marketRowViewModels.count == 3)
        #expect(viewModel.marketRowViewModels[0] == MarketRowViewModel(stockName: "Flower", lastPrice: "134", changePercent: "-10"),
                "Market list should display initial update alphabetically - flower field first")
        #expect(viewModel.marketRowViewModels[1] == MarketRowViewModel(stockName: "Mushroom", lastPrice: "1000", changePercent: "1"),
                "Market list should display initial update alphabetically - mushroom field second")
        #expect(viewModel.marketRowViewModels[2] == MarketRowViewModel(stockName: "Star", lastPrice: "100", changePercent: "5"),
                "Market list should display initial update alphabetically - star field third")

        await sendStreamingUpdate(marketPrices: priceUpdates.inputData)

        try #require(viewModel.marketRowViewModels.count == priceUpdates.expectedResult.count)
        #expect(viewModel.marketRowViewModels == priceUpdates.expectedResult,
                "Market list should display second update alphabetically with correctly updated prices and new markets added where applicable for \(priceUpdates.description)")
    }

    @Test("Stop streaming behaves correctly",
          .tags(.streamingUpdates),
          arguments: [[
            TestData(
                inputData: [MarketPrice.mock(stockName: "Nintendo")],
                expectedResult: [MarketRowViewModel.mock(stockName: "Nintendo")],
                description: "Update #1"
            ),
            TestData(
                inputData: [MarketPrice.mock(stockName: "Sega")],
                expectedResult: [MarketRowViewModel.mock(stockName: "Nintendo")],
                description: "Update #2"
            )
          ]])
    func stopStreaming(for priceUpdates: [TestData<[MarketPrice], [MarketRowViewModel]>]) async throws {
        #expect(viewModel.marketRowViewModels.count == 0,
                "Market list should be empty")
        viewModel.startStreaming()

        await sendStreamingUpdate(marketPrices: priceUpdates[0].inputData)

        try #require(viewModel.marketRowViewModels.count == priceUpdates[0].expectedResult.count)
        #expect(viewModel.marketRowViewModels == priceUpdates[0].expectedResult,
                "Market list should display \(priceUpdates[0].description) after starting streaming")

        viewModel.stopStreaming()
        await sendStreamingUpdate(marketPrices: priceUpdates[1].inputData, expectSuccessful: false)

        try #require(viewModel.marketRowViewModels.count == priceUpdates[1].expectedResult.count)
        #expect(viewModel.marketRowViewModels == priceUpdates[1].expectedResult,
                "Market list should ignore \(priceUpdates[1].description) after starting streaming")
    }

    @Test("Test stop start streaming behaves correctly",
          .tags(.streamingUpdates),
          arguments: [[
            TestData(
                inputData: [MarketPrice.mock(stockName: "Nintendo")],
                expectedResult: [MarketRowViewModel.mock(stockName: "Nintendo")],
                description: "Update #1"
            ),
            TestData(
                inputData: [MarketPrice.mock(stockName: "Sega")],
                expectedResult: [MarketRowViewModel.mock(stockName: "Nintendo")],
                description: "Update #2"
            ),
            TestData(
                inputData: [MarketPrice.mock(stockName: "XBox")],
                expectedResult: [MarketRowViewModel.mock(stockName: "Nintendo"),
                                 MarketRowViewModel.mock(stockName: "XBox")],
                description: "Update #3"
            )
          ]])
    func stopStartStreaming(for priceUpdates: [TestData<[MarketPrice], [MarketRowViewModel]>]) async throws {
        #expect(viewModel.marketRowViewModels.count == 0,
                "Market list should be empty")
        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: priceUpdates[0].inputData)

        try #require(viewModel.marketRowViewModels.count == priceUpdates[0].expectedResult.count)
        #expect(viewModel.marketRowViewModels == priceUpdates[0].expectedResult,
                "Market list should display \(priceUpdates[0].description) after starting streaming")

        viewModel.stopStreaming()
        await sendStreamingUpdate(marketPrices: priceUpdates[1].inputData, expectSuccessful: false)

        try #require(viewModel.marketRowViewModels.count == priceUpdates[1].expectedResult.count)
        #expect(viewModel.marketRowViewModels == priceUpdates[1].expectedResult,
                "Market list should ignore \(priceUpdates[1].description) after stopping streaming")

        viewModel.startStreaming()
        await sendStreamingUpdate(marketPrices: priceUpdates[2].inputData)

        try #require(viewModel.marketRowViewModels.count == priceUpdates[2].expectedResult.count)
        #expect(viewModel.marketRowViewModels == priceUpdates[2].expectedResult,
                "Market list should display \(priceUpdates[2].description) after starting streaming again")
    }
}
