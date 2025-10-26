//
//  MarketsListViewModel.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import Foundation
import Combine

final class MarketsListViewModel: ObservableObject {
    @Published private(set) var marketRowViewModels: [MarketRowViewModel]
    @Published var showAlert = false

    private let dataFormatter: DataFormatter
    private let streamingDataProvider: MarketStreamingDataProvider
    private var subscriptions = Set<AnyCancellable>()
    
    init(dataFormatter: DataFormatter,
         marketRowViewModels: [MarketRowViewModel] = [MarketRowViewModel](),
         streamingDataProvider: MarketStreamingDataProvider) {
        self.dataFormatter = dataFormatter
        self.marketRowViewModels = marketRowViewModels
        self.streamingDataProvider = streamingDataProvider
    }

    func startStreaming() {
        streamingDataProvider.marketPricesPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.showAlert = true
                }
            }, receiveValue: { [weak self] marketPrice in
                self?.update(marketPrice: marketPrice)
            }).store(in: &subscriptions)
        streamingDataProvider.startStreaming()
    }

    func stopStreaming() {
        streamingDataProvider.stopStreaming()
        subscriptions.removeAll()
    }

    private func update(marketPrice: MarketPrice) {
        if let viewModel = viewModel(for: marketPrice.stockName) {
            viewModel.price = Price(marketPrice: marketPrice, dataFormatter: dataFormatter)
        } else {
            marketRowViewModels.append(MarketRowViewModel(dataFormatter: dataFormatter,
                                                          marketPrice: marketPrice))
            marketRowViewModels.sort(by: { $0.stockName < $1.stockName })
        }
    }

    private func viewModel(for stockName: String) -> MarketRowViewModel? {
        marketRowViewModels.first(where: { $0.stockName == stockName })
    }
}
