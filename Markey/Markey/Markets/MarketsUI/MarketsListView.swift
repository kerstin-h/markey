//
//  MarketsListView.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import SwiftUI

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
        contentView
        .alert("Error occured", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Cannot retrieve market data.")
        }
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

    private var contentView: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: .zero) {
                marketsList
                    .padding(.horizontal, 16)
                bottomBanner
            }
            .navigationTitle("Popular Stocks")
            .navigationBarTitleDisplayMode(.inline)
        }
        .ignoresSafeArea()
    }

    private var marketsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .zero) {
                LazyVGrid(columns: columns, spacing: .zero) {
                    Section(header: marketsHeader) {
                        ForEach(viewModel.marketRowViewModels, id: \.stockName) { marketRow in
                            MarketRow(marketRow)
                        }
                        .font(.system(size: 14))
                    }
                }
            }
            .padding(.bottom, 4)
        }
    }

    private var marketsHeader: some View {
        LazyVGrid(columns: columns, spacing: .zero) {
            Text("Market Name".uppercased())
            Text("Stock Price".uppercased())
            Text("Change".uppercased())
        }
        .font(.system(size: 13))
        .foregroundColor(.gray)
    }

    private var bottomBanner: some View {
        VStack(spacing: 16) {
            Divider()
            Group {
                Text("*Data based on a questionable sample of ")
                    .foregroundColor(.gray)
                + Text("[Lightstreamer](https://www.lightstreamer.com)")
                    .foregroundColor(.accentColor)
                    .underline()
                + Text(" demo stocks.")
                    .foregroundColor(.gray)
            }
            .font(.system(size: 13))
            .padding(.horizontal, 16)
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
