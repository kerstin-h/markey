//
//  MarketsListView.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import SwiftUI
import SwiftData

struct MarketsListView: View {
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var viewModel: MarketsListViewModel

    private let columns = [
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .trailing),
        GridItem(.flexible(), alignment: .trailing)
    ]

    init(viewModel: MarketsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: .zero) {
                marketsList
                    .padding(.horizontal, 16)
                Divider()
                Text("*Data based on a questionable sample of Lightstreamer demo stocks.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
            }
            .navigationTitle("Popular Markets*")
            .navigationBarTitleDisplayMode(.inline)
        }
        .ignoresSafeArea()
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                viewModel.startStreaming()
            case .inactive, .background:
                viewModel.stopStreaming()
            @unknown default: break
            }
        }
    }

    private var marketsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .zero) {
                LazyVGrid(columns: columns, spacing: 12) {
                    Section(header: marketsHeader) {
                        ForEach(viewModel.marketList, id: \.stockName) { market in
                            Text(market.stockName)
                            Text(market.lastPrice)
                            Text(market.changePercent)
                        }
                    }
                }
            }
        }
    }

    private var marketsHeader: some View {
        LazyVGrid(columns: columns) {
            Text("Market Name")
            Text("Stock Price")
            Text("Change")
        }
    }
}

#Preview {
    MarketsListView(viewModel: MarketsListViewModel.mock)
}

extension MarketsListViewModel {
    static var mock: MarketsListViewModel {
        RootCoordinator.createViewModel()
    }
}
